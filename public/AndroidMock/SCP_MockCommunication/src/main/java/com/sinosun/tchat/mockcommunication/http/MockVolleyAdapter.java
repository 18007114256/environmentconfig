package com.sinosun.tchat.mockcommunication.http;

import android.content.Context;
import android.text.TextUtils;

import com.android.volley.AuthFailureError;
import com.android.volley.NetworkError;
import com.android.volley.NoConnectionError;
import com.android.volley.ParseError;
import com.android.volley.Response;
import com.android.volley.ServerError;
import com.android.volley.TimeoutError;
import com.android.volley.VolleyError;
import com.sinosun.tchat.business.define.Base;
import com.sinosun.tchat.communication.CommunicationManager;
import com.sinosun.tchat.communication.ITCryption;
import com.sinosun.tchat.communication.bean.CommunicationDownMessage;
import com.sinosun.tchat.communication.error.CommunicationErrorCodeEnum;
import com.sinosun.tchat.communication.http.VolleyAdapter;
import com.sinosun.tchat.communication.http.bean.TchatListener;
import com.sinosun.tchat.communication.http.bean.TchatRequest;
import com.sinosun.tchat.error.ServerPublicErrorCodeEnum;
import com.sinosun.tchat.log.PLog;
import com.sinosun.tchat.messagebus.MessageBus;
import com.sinosun.tchat.mockcommunication.http.bean.MockTchatRequest;
import com.sinosun.tchat.util.CPResourceUtil;
import android.widget.Toast;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import static com.sinosun.tchat.communication.bean.CommunicationDownMessage.HttpMessage.GET;

public class MockVolleyAdapter extends VolleyAdapter {
    private final String TAG = "MockVolleyAdapter";

    private static volatile MockVolleyAdapter instance;

    private Set<String> mockUrls = new HashSet<>();

    private MockVolleyAdapter(Context context, int httpPattern, ITCryption cryption, CommunicationManager communicationManager) {
        super(context, httpPattern, null, communicationManager);
        int arrayId = CPResourceUtil.getArrayId("mock_urls");
        if (arrayId != 0) {
            try {
                String[] tempUrls = Base.getContext().getResources().getStringArray(arrayId);
                for (String url: tempUrls) {
                    mockUrls.add(url);
                }
            } catch (Exception e) {
                PLog.w(TAG, "mockUrls fail, " + e.toString());
                mockUrls.clear();
            }
        }
    }

    public static MockVolleyAdapter getInstance() {
        if (instance == null) {
            synchronized (MockVolleyAdapter.class) {
                if (instance == null) {
                    instance = new MockVolleyAdapter(Base.getContext(), 0, null, null);
                }
            }
        }
        return instance;
    }

    @Override
    public int send(CommunicationDownMessage.HttpMessage msg) {
        // 消息url
        String httpurl;
        String subUrl = MessageBus.getInstance().getUrl(msg.getMsgType());
        if (mockUrls.contains(subUrl)) {
            httpurl = CPResourceUtil.getStringContent("mock_addr") + subUrl;
        } else {
            return -1;
        }
        // 封装上层发下来的消息
        String data = msg.getContent();
        if (data == null) {
            PLog.e(TAG, "sendMessage -- get http msg data is null ... ");
            return -1;
        }
        int msgType = msg.getMsgType();
        String seq = msg.getSeq();

        Map<String, String> param = new HashMap<>(8);
        if (msg.getMethod() == GET) {
            httpurl = addUrlParam(httpurl, data);
        }
        String token = null;
        String encryptUrl = httpurl;
        String encryptBody = data;
        int encryptMethod = msg.getMethod();
        String uniqId = UUID.randomUUID().toString();
        TchatRequest request = new MockTchatRequest(encryptUrl, new VolleyListener(),
                new VolleyErrorListener(), param, msgType, token, encryptMethod, encryptBody,
                httpurl, msg.getMethod(), data, null);
        // 重试的次数
        request.setRetryPolicy(mPlolicy);
        request.setTag(seq);
        request.setUniqId(uniqId);
        request.setResendFlag(false);
        if (mRequestCache != null) {
            // 组件完成后将request放到缓存里，如果网络切换过后再讲重发
            mRequestCache.put(seq, request);
        }
        mRequestQueue.add(request);
        return 0;
    }

    /** 不需要在MessageBus中注册的请求也能通过挡板发送 */
    public void send(String params, String url) {
        String uniqId = UUID.randomUUID().toString();
        String seq = String.valueOf(System.currentTimeMillis());
        TchatRequest request = new MockTchatRequest(url, new VolleyListener(),
                new VolleyErrorListener(), new HashMap<String, String>(), -1, null, CommunicationDownMessage.HttpMessage.POST, null,
                null, CommunicationDownMessage.HttpMessage.POST, params, null);
        // 重试的次数
        request.setRetryPolicy(mPlolicy);
        request.setTag(seq);
        request.setUniqId(uniqId);
        request.setResendFlag(false);
        if (mRequestCache != null) {
            // 组件完成后将request放到缓存里，如果网络切换过后再讲重发
            mRequestCache.put(seq, request);
        }
        mRequestQueue.add(request);
    }

    @Override
    public int reSendMessage() {
        if (tokenErrorRequest.isEmpty()) {
            return 0;
        }
        Iterator<Map.Entry<String, TchatRequest>> iterations = tokenErrorRequest.entrySet().iterator();
        while (iterations.hasNext()) {
            Map.Entry<String, TchatRequest> next = iterations.next();
            TchatRequest cacheRequest = next.getValue();
            iterations.remove();
            if (cacheRequest == null) {
                continue;
            }
            String token = null;
            String body = cacheRequest.getmRequestBody();
            String seq = (String) cacheRequest.getTag();
            String uniqId = UUID.randomUUID().toString();
            TchatRequest request = new MockTchatRequest(cacheRequest.getUrl(),
                    cacheRequest.getmRespnoseListener(), cacheRequest.getmErrorLisener(),
                    cacheRequest.getParamMap(), cacheRequest.getType(), token, cacheRequest.getMethod(),
                    body, cacheRequest.getOldUrl(), cacheRequest.getOldMethod(),
                    cacheRequest.getOldBody(), null);
            request.setTag(seq);
            request.setUniqId(uniqId);
            request.setRetryPolicy(mPlolicy);
            request.setResendFlag(true);
            mRequestQueue.add(request);
        }
        return 0;
    }

    /**
     * volley请求响应
     */
    public class VolleyListener implements Response.Listener<JSONObject> {

        @Override
        public void onResponse(JSONObject response) {
            try {
                String seq = (String) response.get("seq");
                if (!TextUtils.isEmpty(seq)) {
                    TchatRequest request = mRequestCache.remove(seq);
                    int resultCode = response.getInt("resultCode");
                    if (resultCode == 401 || resultCode == 403) {
                        if (request != null && request.getTag() != null && !request.isResendFlag()) {
                            tokenErrorRequest.put(request.getTag().toString(), request);
                            return;
                        }
                    }
                }
            } catch (Exception e) {
                PLog.e(TAG, "handleResponse seq is null");
            }
            if (httpResponse != null) {
                httpResponse.onResponse(response.toString());
            }
        }
    }

    /**
     * volley请求异常监听
     */
    public class VolleyErrorListener implements TchatListener {
        @Override
        public void onErrorResponse(VolleyError error) {
            PLog.e(TAG, "onErrorResponse" + error.getMessage());
        }

        @Override
        public void onErrorResponse(VolleyError error, int type, Object seq) {
            int ret = ServerPublicErrorCodeEnum.SUCCESS.getCode();
            if (error instanceof NetworkError) {
                ret = CommunicationErrorCodeEnum.ERR_NETWORK_DISCONNECTED
                        .getCode();
            } else if (error instanceof ServerError) {
                ret = CommunicationErrorCodeEnum.ERR_SERVER_ERROR.getCode();
            } else if (error instanceof AuthFailureError) {
                ret = CommunicationErrorCodeEnum.ERR_SERVICE_FAIL.getCode();
            } else if (error instanceof ParseError) {
                ret = CommunicationErrorCodeEnum.ERR_FORBINDDEN.getCode();
            } else if (error instanceof NoConnectionError) {
                ret = CommunicationErrorCodeEnum.ERR_NETWORK_DISCONNECTED.getCode();
            } else if (error instanceof TimeoutError) {
                ret = CommunicationErrorCodeEnum.ERR_REQUEST_TIMEOUT.getCode();
            } else if (error instanceof VolleyError) {
                // 默认是VOLLEY 内部错误
                ret = CommunicationErrorCodeEnum.ERR_REQUEST_TIMEOUT.getCode();
            }

            if (CommunicationErrorCodeEnum.ERR_SERVICE_FAIL.getCode() == ret) {
                TchatRequest request = mRequestCache.remove(seq.toString());
                if (request != null && request.getTag() != null && !request.isResendFlag()) {
                    tokenErrorRequest.put(request.getTag().toString(), request);
                    return;
                }
            } else {
                PLog.e(TAG, "onErrorResponse type: 0x" + Integer.toHexString(type) + ", ret: " +
                        ((error != null && error.networkResponse != null) ? error.networkResponse.statusCode : ret));
            }
			
			Toast.makeText(Base.getContext(), "挡板服务器未知错误 " + ret, Toast.LENGTH_LONG).show();
			
            mRequestCache.remove(seq);
            if (httpResponse != null) {
                httpResponse.onError(ret, seq.toString(), type);
            }
        }
    }
}
