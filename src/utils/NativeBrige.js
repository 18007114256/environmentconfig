import H5BrigeImpl from "./H5BrigeImpl.js";

class NativeBrige {
    instance;
    nativeBrigeImpl;
    constructor() {
        this.nativeBrigeImpl = H5BrigeImpl;
    }
    getInstance() {
        if (!this.instance) {
            this.instance = new NativeBrige();
        }
        return this.instance;
    }
    setNativeBrigeImpl(impl) {
        if (impl) {
            this.nativeBrigeImpl = impl;
        }
    }
    checkEnv(info) {
        return new Promise((res, rej) => {
            this.nativeBrigeImpl
                .checkEnv(info)
                .then((data) => {
                    res(data);
                })
                .catch((err) => {
                    rej(err);
                });
        });
    }

    creatProject(info) {
        return this.checkEnv(info).then((cdata) => {
            return new Promise((res, rej) => {
                if (cdata.type) {
                    this.nativeBrigeImpl
                        .creatProject(info)
                        .then((data) => {
                            res(data);
                        })
                        .catch((err) => {
                            rej(err);
                        });
                } else {
                    let err = cdata.msg;
                    rej(err);
                }
            }).catch((err) => {
                return new Promise((res, rej) => {
                    rej(err);
                });
            });
        });
    }
    getProject(id) {
        return this.nativeBrigeImpl.getProject(id);
    }
    getSyncDataInfo(query) {
        return new Promise((res, rej) => {
            this.nativeBrigeImpl
                .getSyncDataInfo(query)
                .then((data) => {
                    res(data);
                })
                .catch((err) => {
                    rej(err);
                });
        });
    }
    getProjectInfo(info) {
        return this.nativeBrigeImpl.getProjectInfo(info);
    }
    getEnvironmentList(info) {
        return this.nativeBrigeImpl.getEnvironmentList(info);
    }
    setProjectInfo(info) {
        return new Promise((res, rej) => {
            this.nativeBrigeImpl
                .setProjectInfo(info)
                .then((data) => {
                    res(data);
                })
                .catch((err) => {
                    rej(err);
                });
        });
    }
    deleteLocalConfig(projectList) {
        return this.nativeBrigeImpl.deleteLocalConfig(projectList);
    }
}

export default new NativeBrige().getInstance();
