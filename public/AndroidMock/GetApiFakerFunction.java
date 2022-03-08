package com.sinosun.browser.commfunction;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.text.TextUtils;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.sinosun.browser.BrowserFunctionMgr;
import com.sinosun.browser.bean.ApiFakerBean;
import com.sinosun.browser.bean.ResponseData;
import com.sinosun.browser.bean.ShareData;
import com.sinosun.tchat.base.VDialogAdapter;
import com.sinosun.tchat.bean.ShareBean;
import com.sinosun.tchat.bean.ShareResponseBean;
import com.sinosun.tchat.business.define.Base;
import com.sinosun.tchat.communication.IHttpResponse;
import com.sinosun.tchat.constants.UserConstants;
import com.sinosun.tchat.extendInterface.browser.BrowserXFunctionHandler;
import com.sinosun.tchat.extendInterface.browser.CallbackFunction;
import com.sinosun.tchat.log.PLog;
import com.sinosun.tchat.mockcommunication.http.MockH5VolleyAdapter;
import com.sinosun.tchat.util.JsonTools;

import java.util.ArrayList;

public class GetApiFakerFunction implements BrowserXFunctionHandler {
    private final static String TAG = GetApiFakerFunction.class.getSimpleName();
    private CallbackFunction callbackFunction;

    @Override
    public String getFunctionName() {
        return this.getClass().getSimpleName();
    }

    @Override
    public void handlerXFunction(String data, final CallbackFunction callbackFunction) {
        this.callbackFunction = callbackFunction;
        if (!TextUtils.isEmpty(data)) {
            ApiFakerBean bean = JsonTools.json2BeanObject(data, ApiFakerBean.class);
            if (bean != null) {
                MockH5VolleyAdapter.getInstance().send(bean.getParams(), bean.getSendUrl(), new IHttpResponse() {
                    @Override
                    public void onResponse(String data, int msgType, String retCode, String seq, String time) {
                        //scp没有使用
                    }

                    @Override
                    public void onResponse(String data) {
                        MockH5VolleyAdapter.getInstance().removeCallBack(bean.getUrl().getUrlApi());
                        if (callbackFunction != null){
                            ResponseData responseData = new ResponseData();
                            responseData.setRetCode(0);
                            responseData.setData(data);
                            callbackFunction.onCallBack(JS_RET_SUCCESSED, JsonTools.bean2Json(responseData));
                        }
                    }

                    @Override
                    public void onError(int ret, String seq, int requestType) {
                        MockH5VolleyAdapter.getInstance().removeCallBack(bean.getUrl().getUrlApi());
                        if (callbackFunction != null) {
                            ResponseData responseData = new ResponseData();
                            responseData.setRetCode(ret);
                            callbackFunction.onCallBack(JS_RET_FIALED, JsonTools.bean2Json(responseData));
                        }
                    }
                });
            } else {
                if (callbackFunction != null) {
                    callbackFunction.onCallBack(JS_RET_FIALED, "");
                }
            }
        } else {
            if (callbackFunction != null) {
                callbackFunction.onCallBack(JS_RET_FIALED, "");
            }
        }
    }
}

