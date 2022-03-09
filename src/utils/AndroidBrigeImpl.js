import { setStorage, getStorage } from "./commonUtils.js";
const exec = window.require("child_process").exec;
const { ipcRenderer: ipc } = window.require("electron");
const path = window.require("path"); //获取文件系统模块，负责读写文件
const fs = window.require("fs"); //获取文件系统模块，负责读写文件

let _this = null;
let _res = null;
let _rej = null;
let _vue = null;
class AndroidBrigeImpl {
    instance;
    runExecId = 0;
    runExecMap = {};
    constructor() {
        ipc.on("transData", this.transDataFn);
        _this = this;
    }
    getInstance() {
        if (!this.instance) {
            this.instance = new AndroidBrigeImpl();
        }
        return this.instance;
    }
    
    getApilistPath() {
        let num = __dirname.indexOf("node_modules");
        let devSrc = __dirname.slice(0, num - 1);
        let DevSinosun = path.join(devSrc, `./public/scpmock/data/api-list.db`);
        let cmdPath =
            process.env.NODE_ENV === "development"
                ? DevSinosun
                : path.join(__dirname, `./scpmock/data/api-list.db`);
        return cmdPath;
    }
    initDB() {
        //store api base info
        // console.log('Datastore', Datastore)
        // this.db = {
        //     apiList: new Datastore({ filename: this.getScriptPath(), autoload: true }),
        // };
        let db = fs
            .readFileSync(this.getApilistPath())
            .toString()
            .split("\n")
            .filter((item) => item != "")
            .map((item) => JSON.parse(item));
        this.db = db;
        console.log("db", db);
    }

    getSyncDataInfo(query) {
        this.initDB();
        let _this = this;
        let { multi } = query;
        console.log("H5 - getSyncDataInfo - ");
        let obj;
        if (multi) {
            delete query.multi;
            // obj = {
            //     $or: query.project.map((item) => {
            //         return {
            //             project: item,
            //         };
            //     }),
            // };
            obj = query.project;
        } else {
            delete query.multi;
            obj = [query.project];
        }
        console.log("obj", obj);
        return new Promise((res) => {
            let docs = [];
            obj.forEach((item) => {
                _this.db.forEach((ditem) => {
                    if (item == ditem.project) {
                        docs.push(ditem);
                    }
                });
            });
            console.log("docs", docs);
            res(
                docs
                    .filter((item) => !item.deleted)
                    .map((item) => {
                        return { name: item.name, checked: false };
                    }),
            );
            // db.apiList.find(obj).exec(function (err, docs) {
            //     if (err) {
            //         rej(err);
            //         return;
            //     }
            //     console.log("err", err);
            //     console.log("docs", docs);
            //     res(
            //         docs
            //             .filter((item) => !item.deleted)
            //             .map((item) => {
            //                 return { name: item.name, checked: false };
            //             }),
            //     );
            // });
        });
    }
    checkEnv() {
        console.log("Android - checkEnv - ");
        return new Promise((res) => {
            _res = res;
            let obj = {
                type: true,
                code: 200,
            };
            _res(obj);
        });
    }
    getScriptPath() {
        let num = __dirname.indexOf("node_modules");
        let devSrc = __dirname.slice(0, num - 1);
        let DevSinosun = path.join(devSrc, `./public/AndroidMock`);
        let cmdPath =
            process.env.NODE_ENV === "development"
                ? DevSinosun
                : path.join(__dirname, `./AndroidMock`);
        return cmdPath;
    }
    creatProject(info) {
        console.log("Android - creatProject - ", info);
        // let basePath = info.basePath;
        _vue = info._vue;
        return new Promise((res, rej) => {
            _res = res;
            _rej = rej;
            // _this.checkMockThen(basePath).then((resData) => {
                // if (resData.type) {
                    let obj = {
                        type: true,
                        code: 200,
                    };
                    _res(obj);
                    // console.log("成功", resData);
                // } else {
                //     let obj = {
                //         type: false,
                //         code: 400,
                //     };
                //     _res(obj);
                //     console.log("失败", resData);
                    // _this.iPythonThen(basePath).then((pythonData) => {
                    //     if (pythonData.type) {
                    //         _this.doCreatProject(basePath).then((thenData) => {
                    //             if (thenData.type) {
                    //                 _this.doCompileAAR(basePath).then((compileAAR) => {
                    //                     if (compileAAR.type) {
                    //                         _this.copyArrThen(basePath).then((cpArrData) => {
                    //                             if (cpArrData.type) {
                    //                                 _this
                    //                                     .doSetMockFlag(basePath)
                    //                                     .then((setMockFlag) => {
                    //                                         if (setMockFlag.type) {
                    //                                             _res(setMockFlag);
                    //                                         } else {
                    //                                             _rej(setMockFlag);
                    //                                         }
                    //                                     });
                    //                             } else {
                    //                                 _rej(cpArrData);
                    //                             }
                    //                         });
                    //                     } else {
                    //                         _rej(compileAAR);
                    //                     }
                    //                 });
                    //             } else {
                    //                 _rej(thenData);
                    //             }
                    //         });
                    //     } else {
                    //         _rej(pythonData);
                    //     }
                    // });
                // }
            // });
        });
    }
    closeFn(time, msg) {
        let t = time;
        _vue.loading && _vue.loading.close();
        _vue.loadingFn(`${msg}\n${time}秒后自动关闭,请手动重启工具`);
        setInterval(() => {
            t--;
            if (t == 0) {
                ipc.send("close");
            }
        }, 1000);
    }
    checkMockThen(basePath) {
        let cmdPath = _this.getScriptPath();
        return new Promise((res) => {
            _this.runExec(
                `checkMockThen.bat ${basePath}`,
                // cmdStr,
                cmdPath + "\\Mockscript",
                (data) => {
                    console.log("data-stdout", data);
                    //----------------
                    //----------------      //  转圈提示 正在安装python     //----------------
                    //----------------
                    if (data.indexOf("ele_python_not_installed") != -1) {
                        setTimeout(() => {
                            _vue.loading && _vue.loading.close();
                            _vue.loadingFn("Installing Python...");
                        }, 1500);
                        // let msg = data.split("ele_python_not_installed ")[1];
                        // let obj = {
                        //     type: false,
                        //     code: 404,
                        //     msg: msg,
                        // };
                        // _rej(obj);
                        console.log("失败", data);
                    }
                    if (data.indexOf("ele_python_install_failed") != -1) {
                        let obj = {
                            type: false,
                            code: 404,
                            msg: "自动安装python失败，请手动安装后再进行重试",
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }
                    if (data.indexOf("ele_python_install_competed") != -1) {
                        let time = 10;
                        let msg = "Python安装成功，重启工具后生效";
                        _this.closeFn(time, msg);
                        // let msg = "python安装成功";
                        // let obj = {
                        //     type: false,
                        //     code: 404,
                        //     msg: msg,
                        // };
                        // res(obj);
                        // console.log("失败", data);
                    }
                    if (data.indexOf("ele_Python_exsits") != -1) {
                        let obj = {
                            type: true,
                            code: 200,
                        };
                        res(obj);
                        console.log("成功", data);
                    }
                    // if (data.indexOf("ele_mock_exsits") != -1) {
                    //     let obj = {
                    //         type: true,
                    //         code: 200,
                    //     };
                    //     res(obj);
                    //     console.log("成功", data);
                    // }
                    // if (data.indexOf("ele_mock_then") != -1) {
                    //     let obj = {
                    //         type: false,
                    //         code: 404,
                    //         msg: "当前工程不存在插件代码，即将进行安装...",
                    //     };
                    //     res(obj);
                    //     console.log("失败", data);
                    // }
                },
                (data) => {
                    console.log("data-stderr", data);
                    if (data.indexOf("ele_fail") != -1) {
                        let obj = {
                            type: false,
                            code: 400,
                            msg: "创建项目失败，请按照操作手册安装环境",
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }
                },
            );
        });
    }

    iPythonThen(basePath) {
        let cmdPath = _this.getScriptPath();
        return new Promise((res) => {
            _this.runExec(
                `installPythonComplete.bat ${basePath}`,
                // cmdStr,
                cmdPath + "\\Mockscript",
                (data) => {
                    console.log("data-stdout", data);
                    if (data.indexOf("ele_mock_then") != -1) {
                        let obj = {
                            type: true,
                            code: 200,
                            msg: "当前工程不存在插件代码，即将进行安装...",
                        };
                        res(obj);
                        console.log("失败", data);
                    }
                },
                (data) => {
                    console.log("data-stderr", data);
                    if (data.indexOf("ele_fail") != -1) {
                        let obj = {
                            type: false,
                            code: 400,
                            msg: "创建项目失败，请按照操作手册安装环境",
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }
                },
            );
        });
    }

    doCreatProject(basePath) {
        let cmdPath = _this.getScriptPath();
        return new Promise((res) => {
            _this.runExec(
                `createProject.bat ${cmdPath} ${basePath}`,
                // cmdStr,
                cmdPath + "\\Mockscript",
                (data) => {
                    console.log("data-stdout", data);
                    if (data.indexOf("ele_makeJar") != -1) {
                        let msg = data.split("ele_makeJar ")[1];
                        _vue.loading.close();
                        _vue.loadingFn(msg);
                    }
                    if (
                        data.indexOf("ele_compile_then") != -1 &&
                        data.indexOf("echo ele_compile_then") == -1
                    ) {
                        let obj = {
                            type: true,
                            code: 200,
                        };
                        res(obj);
                        console.log("成功", data);
                    }
                    if (data.indexOf("ele_fail") != -1) {
                        let obj = {
                            type: false,
                            code: 400,
                            msg: "创建项目失败，请按照操作手册安装环境",
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }
                },
                (data) => {
                    console.log("data-stderr", data);
                    if (data.indexOf("ele_fail") != -1) {
                        let obj = {
                            type: false,
                            code: 400,
                            msg: "创建项目失败，请按照操作手册安装环境",
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }
                },
            );
        });
    }
    doCompileAAR(basePath) {
        let cmdPath = _this.getScriptPath();
        return new Promise((res) => {
            _this.runExec(
                `compileAAR.bat ${basePath}`,
                // cmdStr,
                cmdPath + "\\Mockscript",
                (data) => {
                    console.log("data-stdout", data);
                    if (data.indexOf("ele_makeAar") != -1) {
                        let msg = data.split("ele_makeAar ")[1];
                        _vue.loading.close();
                        _vue.loadingFn(msg);
                    }
                    if (data.indexOf("ele_copy_aar_then") != -1) {
                        let obj = {
                            type: true,
                            code: 200,
                        };
                        res(obj);
                        console.log("成功", data);
                    }
                    if (data.indexOf("ele_fail") != -1) {
                        let obj = {
                            type: false,
                            code: 400,
                            msg: "创建项目失败，请按照操作手册安装环境",
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }
                },
                (data) => {
                    console.log("data-stderr", data);
                    if (data.indexOf("ele_fail") != -1) {
                        let obj = {
                            type: false,
                            code: 400,
                            msg: "创建项目失败，请按照操作手册安装环境",
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }
                },
            );
        });
    }

    copyArrThen(basePath) {
        let cmdPath = _this.getScriptPath();
        return new Promise((res) => {
            _this.runExec(
                `copyAarThen.bat ${basePath}`,
                // cmdStr,
                cmdPath + "\\Mockscript",
                (data) => {
                    console.log("data-stdout", data);
                    if (data.indexOf("ele_mock_flag_then") != -1) {
                        let obj = {
                            type: true,
                            code: 200,
                        };
                        res(obj);
                        console.log("成功", data);
                    }
                },
                (data) => {
                    console.log("data-stderr", data);
                    if (data.indexOf("ele_fail") != -1) {
                        let obj = {
                            type: false,
                            code: 400,
                            msg: "创建项目失败，请按照操作手册安装环境",
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }
                },
            );
        });
    }

    doSetMockFlag(basePath) {
        let cmdPath = _this.getScriptPath();
        return new Promise((res) => {
            _this.runExec(
                `setMockFlag.bat ${basePath}`,
                // cmdStr,
                cmdPath + "\\Mockscript",
                (data) => {
                    console.log("data-stdout", data);
                    if (data.indexOf("ele_success") != -1) {
                        let obj = {
                            type: true,
                            code: 200,
                        };
                        res(obj);
                        console.log("成功", data);
                    }
                    if (data.indexOf("ele_fail") != -1) {
                        let obj = {
                            type: false,
                            code: 400,
                            msg: "创建项目失败，请按照操作手册安装环境",
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }
                },
                (data) => {
                    console.log("data-stderr", data);
                    if (data.indexOf("ele_fail") != -1) {
                        let obj = {
                            type: false,
                            code: 400,
                            msg: "创建项目失败，请按照操作手册安装环境",
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }
                },
            );
        });
    }

    getProject(id) {
        console.log("Android - getProject - ", id);
    }
    getProjectInfo() {
        console.log("Android - getProjectInfo - ");
        let info = {
            interfaceList: JSON.parse(getStorage("projectMap-pluginAndroid") || "{}"),
        };
        return info;
    }
    setProjectInfo(info) {
        console.log("Iso - setProjectInfo - ", info);
        let { mockFlag, interfaceList, id } = info;
        let projectList = JSON.parse(getStorage("projectList-pluginAndroid") || "[]");
        let setInfo = projectList
            .filter((item) => item.id == id)
            .map((item) => {
                return {
                    url: item.basePath,
                    ip: item.ip,
                };
            })[0];
        let interfaceStr = interfaceList.map((item) => item.name).join("%*");

        return new Promise((res, rej) => {
            _res = res;
            _rej = rej;
            let cmdPath = _this.getScriptPath();
            let cmdStr = `setProjectInfo.bat ${setInfo.url} http://${setInfo.ip}/~scpmock ${
                mockFlag ? interfaceStr : ""
            }`;
            _this.runExec(
                cmdStr,
                cmdPath + "\\Mockscript",
                (data) => {
                    if (data.indexOf("ele_success") != -1) {
                        let obj = {
                            type: true,
                            code: data,
                        };
                        _res(obj);
                        console.log("成功", data);
                    }
                },
                (data) => {
                    if (data.indexOf("ele_fail") != -1) {
                        let obj = {
                            type: false,
                            code: 400,
                            msg: data,
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }
                },
            );
        });
    }

    transDataFn(event, datas) {
        let { id, data } = datas;
        _this.runExecMap[id] && _this.runExecMap[id](data);
    }
    runExec(cmdStr, cmdPath, stdoutCB, stderrCB, closeCB = () => {}) {
        console.log("cmdStr", cmdStr);
        var binaryEncoding = "GBK";
        let workerProcess = exec(cmdStr, { cwd: cmdPath, encoding: binaryEncoding });
        // 打印正常的后台可执行程序输出
        workerProcess.stdout.on("data", function (data) {
            _this.runExecId++;
            _this.runExecMap[_this.runExecId] = stdoutCB;
            console.log("runExec ==> stdout: " + data);
            ipc.send("doTransData", {
                data: data,
                id: _this.runExecId,
            });
        });
        // 打印错误的后台可执行程序输出
        workerProcess.stderr.on("data", function (data) {
            _this.runExecId++;
            _this.runExecMap[_this.runExecId] = stderrCB;
            console.log("runExec ==> stderr: " + data);
            ipc.send("doTransData", {
                data: data,
                id: _this.runExecId,
            });
        });
        // 退出之后的输出
        workerProcess.on("close", function (code) {
            console.log("out code：" + code);
            closeCB(code);
        });
    }
    deleteLocalConfig(projectList) {
        console.log("Android - deleteLocalConfig - ");
        let projectMap = JSON.parse(getStorage("projectMap-pluginAndroid") || "{}");
        let keyList = Object.keys(projectMap);
        let obj = (projectList || [])
            .filter((item) => keyList.includes(`${item.id}`))
            .map((item) => item.id);
        keyList.forEach((item) => {
            if (!obj.includes(Number(item))) {
                delete projectMap[item];
            }
        });
        setStorage("projectMap-pluginAndroid", JSON.stringify(projectMap));
    }
}

export default new AndroidBrigeImpl().getInstance();
