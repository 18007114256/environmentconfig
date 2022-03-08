package com.sinosun.tchat.cmockcommunication;

import android.util.Log;

import com.sinosun.tchat.business.define.Base;
import com.sinosun.tchat.business.define.IServerErrorCode;
import com.sinosun.tchat.business.define.ITBusiness;
import com.sinosun.tchat.communication.IHttpResponse;
import com.sinosun.tchat.communication.ITCommunication;
import com.sinosun.tchat.constants.Component;
import com.sinosun.tchat.mockcommunication.http.MockH5VolleyAdapter;
import com.sinosun.tchat.mockcommunication.http.MockVolleyAdapter;
import com.sinosun.tchat.util.CPResourceUtil;

import java.util.Map;

public class TMock extends Base implements IMock{
	
	private static String MOCK_SWITCH_ON = "1";
    private static String MOCK_SWITCH_OFF = "0";
    private String mock_switch = MOCK_SWITCH_OFF;
	

    public TMock() {

    }

    @Override
    public int release() {
        return 0;
    }

    @Override
    public String getModelInfo() {
        return null;
    }

    @Override
    public String getModelFlag() {
        return null;
    }

    @Override
    public void onCreate() {
        init();
    }

    @Override
    public void onStart() {

    }

    @Override
    public int switchCompany(String companyId) {
        return 0;
    }

    @Override
    public IServerErrorCode getModelServerErrorCode() {
        return null;
    }

    @Override
    public int getModelType() {
        return 0;
    }

    private void init() {
		mock_switch = CPResourceUtil.getStringContent("mock_switch");
		if(MOCK_SWITCH_ON.equals(mock_switch)){
			Log.e("TMock", "init: ---Mock挡板已开启---");
			ITBusiness business = Base.getComponent(Component.COMMUNICATION);
			if (business instanceof ITCommunication) {
				ITCommunication itCommunication = ((ITCommunication) business);
				itCommunication.installMockAdapter(MockVolleyAdapter.getInstance());
			}
		} else {
            Log.e("TMock", "init: ---Mock挡板已关闭---");
        } 
    }

    @Override
    public void sendRequest(String params, String url) {
		if(MOCK_SWITCH_ON.equals(mock_switch)){
            Log.e("TMock", "sendRequest: ---Mock挡板已开启---");
            MockVolleyAdapter.getInstance().send(params, url);
        } else {
            Log.e("TMock", "sendRequest: ---Mock挡板已关闭---");
        }
    }
}
