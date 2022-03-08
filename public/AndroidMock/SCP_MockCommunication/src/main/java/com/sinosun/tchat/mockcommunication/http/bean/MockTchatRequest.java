package com.sinosun.tchat.mockcommunication.http.bean;

import com.android.volley.NetworkResponse;
import com.android.volley.ParseError;
import com.android.volley.Response;
import com.android.volley.toolbox.HttpHeaderParser;
import com.sinosun.tchat.communication.ITCryption;
import com.sinosun.tchat.communication.http.bean.TchatListener;
import com.sinosun.tchat.communication.http.bean.TchatRequest;
import com.sinosun.tchat.util.StringUtil;

import org.json.JSONObject;

import java.nio.charset.StandardCharsets;
import java.util.Map;

public class MockTchatRequest extends TchatRequest {
    public MockTchatRequest(String url, Response.Listener<JSONObject> listener, TchatListener errorListener, Map<String, String> map, int typeValue, String token, int method, String body, String oldUrl, int oldMethod, String oldBody, ITCryption itCryption) {
        super(url, listener, errorListener, map, typeValue, token, method, body, oldUrl, oldMethod, oldBody, itCryption);
    }

    @Override
    protected Response<JSONObject> parseNetworkResponse(NetworkResponse response) {
        // TODO: 2021/6/18 不需要在MessageBus中注册的请求也能通过挡板发送 */
        try {
            String jsonString = new String(response.data, StandardCharsets.UTF_8);
            int code = StringUtil.parseInt(jsonString);
            if (code > 0) {
                return processErrorResponse(code, response);
            }
            // logd("success"+jsonString);
            String seq = (String) getTag();
            JSONObject responeJSON = new JSONObject(jsonString);
            responeJSON.put("type", type);
            responeJSON.put("seq", seq);
            return Response.success(responeJSON,
                    HttpHeaderParser.parseCacheHeaders(response));
        } catch (Exception e) {
            return Response.error(new ParseError(e));
        }
    }
}
