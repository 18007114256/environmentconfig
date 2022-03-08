package com.sinosun.browser.bean;

public class ApiFakerBean {

    private String params;
    private ApiFakerUrlBean Url;

    public String getSendUrl(){
        return Url.getUrlApi()+Url.getCmd();
    }

    public String getParams() {
        return params;
    }

    public void setParams(String params) {
        this.params = params;
    }

    public ApiFakerUrlBean getUrl() {
        return Url;
    }

    public void setUrl(ApiFakerUrlBean url) {
        Url = url;
    }
}
