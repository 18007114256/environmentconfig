const exec = window.require("child_process").exec;
const path = window.require("path");
const fs = window.require("fs"); //获取文件系统模块，负责读写文件
import { setStorage, getStorage, exists, copy } from "./commonUtils.js";

let _res = null;
let _rej = null;
let _tostr = null;
class IosBrigeImpl {
    instance;
    runExecMap = {};
    runExecId = 0;
    constructor() {}
    getInstance() {
        if (!this.instance) {
            this.instance = new IosBrigeImpl();
        }
        return this.instance;
    }
    copyIos() {
        let num = __dirname.indexOf("node_modules");
        let devSrc = __dirname.slice(0, num - 1);
        let DevSinosun = path.join(devSrc, "./public/ruby/ios");
        let toSrc = _tostr;
        let cmdPath =
            process.env.NODE_ENV === "development"
                ? DevSinosun
                : path.join(__dirname, "./ruby/ios");

        exists(cmdPath, toSrc, copy);
    }

    getScriptPath() {
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
            .readFileSync(this.getScriptPath())
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

    checkEnv(info) {
        let _this = this;
        let password = info.password;
        console.log("iOS - checkEnv - ");
        return new Promise((res, rej) => {
            _res = res;
            _rej = rej;
            let cmdStr = `sh checkEnv.command ${password ? password : ""}`;
            let num = __dirname.indexOf("node_modules");
            let devSrc = __dirname.slice(0, num - 1);
            let DevSinosun = path.join(devSrc, "./public/ruby");
            let cmdPath =
                process.env.NODE_ENV === "development"
                    ? DevSinosun
                    : path.join(__dirname, "./ruby");

            this.runExec(
                cmdStr,
                cmdPath,
                (data) => {
                    if (data.indexOf("ele_success") != -1) {
                        _tostr = data.split("ENV_HOME")[1] + "/Desktop/Mock_Download";
                        let obj = {
                            type: true,
                            code: 200,
                            msg: data,
                        };
                        _res(obj);
                        _this.copyIos();
                        console.log("成功", data);
                    }
                    if (data.indexOf("ele_fail") != -1) {
                        let obj = {
                            type: false,
                            code: 400,
                            msg: data,
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }

                    if (data.indexOf("ele_password") != -1) {
                        let obj = {
                            type: "password",
                            code: 401,
                            msg: data,
                        };
                        _rej(obj);
                        console.log("失败", data);
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
    creatProject(info) {
        console.log("iOS - creatProject - ", info);
        let basePath = info.basePath;
        return new Promise((res, rej) => {
            _res = res;
            _rej = rej;
            let num = __dirname.indexOf("node_modules");
            let devSrc = __dirname.slice(0, num - 1);
            let DevSinosun = path.join(devSrc, "./public/ruby");
            let cmdPath =
                process.env.NODE_ENV === "development"
                    ? DevSinosun
                    : path.join(__dirname, "./ruby");

            let cmdStr = `sh electron.command ${basePath} ${_tostr}`;
            let obj = {
                type: true,
                code: 200,
                msg: cmdPath + cmdStr,
            }
            _res(obj);
            console.log("成功", obj);
            // this.runExec(
            //     cmdStr,
            //     cmdPath,
            //     (data) => {
            //         if (data.indexOf("ele_success") != -1) {
            //             let obj = {
            //                 type: true,
            //                 code: 200,
            //                 msg: data,
            //             };
            //             _res(obj);
            //             console.log("成功", data);
            //         }
            //         if (data.indexOf("ele_fail") != -1) {
            //             let obj = {
            //                 type: false,
            //                 code: 400,
            //                 msg: data,
            //             };
            //             _rej(obj);
            //             console.log("失败", data);
            //         }
            //     },
            //     (data) => {
            //         if (data.indexOf("ele_fail") != -1) {
            //             let obj = {
            //                 type: false,
            //                 code: 400,
            //                 msg: data,
            //             };
            //             _rej(obj);
            //             console.log("失败", data);
            //         }
            //     },
            // );
        });
    }
    getProject(id) {
        console.log("iOS - getProject - ", id);
    }
    getProjectInfo() {
        console.log("iOS - getProjectInfo - ");
        let info = {
            interfaceList: JSON.parse(getStorage("projectMap-pluginIos") || "{}"),
        };
        return info;
    }
    getEnvironmentList(basePath) {
        console.log("iOS - getEnvironmentList -");
        let cmdStr = `ruby findEnv.rb '${basePath}'`;
        let num = __dirname.indexOf("node_modules");
        let devSrc = __dirname.slice(0, num - 1);
        let DevSinosun = path.join(devSrc, "./public/ruby");
        let cmdPath =
            process.env.NODE_ENV === "development"
                ? DevSinosun
                : path.join(__dirname, "./ruby");
        return new Promise((res) => {
            this.runExec(
                cmdStr,
                cmdPath,
                (data) => {
                    console.log("iOS-env-", data);            
                    if (data.indexOf("-Env-") != -1) {
                        res(data);
                        console.log("读取环境成功", data);
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
    modifyEnv(envPath, projectPath, envName) {
        console.log("-----iOS - modifyEnv - ", envPath , projectPath , envName);
        let cmdStr = `ruby modifyEnvConfig.rb '${envPath}' '${projectPath}' '${envName}'`;
        console.log(cmdStr);
        let num = __dirname.indexOf("node_modules");
        let devSrc = __dirname.slice(0, num - 1);
        let DevSinosun = path.join(devSrc, "./public/ruby");
        let cmdPath =
            process.env.NODE_ENV === "development"
                ? DevSinosun
                : path.join(__dirname, "./ruby");
        return new Promise((res) => {
            this.runExec(
                cmdStr,
                cmdPath,
                (data) => {
                    console.log("data-modifyEnv", data);
                    if (data.indexOf("success") != -1) {
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
                            msg: "配置失败",
                        };
                        _rej(obj);
                        console.log("失败", data);
                    }
                },
            );
        });
    }
    setProjectInfo(info) {
        console.log("iOS - setProjectInfo - ", info);
        let { mockFlag, interfaceList, id } = info;
        console.log("iOS - setProjectInfo - ", mockFlag);
        let projectList = JSON.parse(getStorage("projectList-pluginIos") || "[]");
        let setInfo = projectList
            .filter((item) => item.id == id)
            .map((item) => {
                return {
                    url: item.basePath,
                    ip: item.ip,
                };
            })[0];
        let interfaceStr = interfaceList.map((item) => item.name).join(",");

        return new Promise((res, rej) => {
            _res = res;
            _rej = rej;
            let cmdStr = `sh mockApi.command '${setInfo.url}' 'http://${setInfo.ip}/~scpmock' '${
                mockFlag ? interfaceStr : ""
            }'`;
            let num = __dirname.indexOf("node_modules");
            let devSrc = __dirname.slice(0, num - 1);
            let DevSinosun = path.join(devSrc, "./public/ruby");
            let cmdPath =
                process.env.NODE_ENV === "development"
                    ? DevSinosun
                    : path.join(__dirname, "./ruby");

            this.runExec(
                cmdStr,
                cmdPath,
                (data) => {
                    if (data.indexOf("ele_success") != -1) {
                        let obj = {
                            type: true,
                            code: 200,
                            msg: data,
                        };
                        _res(obj);
                        console.log("成功", data);
                    }
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

    runExec(cmdStr, cmdPath, stdoutCB, stderrCB, closeCB = () => {}) {
        let workerProcess = exec(cmdStr, { cwd: cmdPath });
        // 打印正常的后台可执行程序输出 
        workerProcess.stdout.on("data", function (data) {
            console.log("runExec ==> stdout: " + data);
            stdoutCB(data);
        });
        // 打印错误的后台可执行程序输出
        workerProcess.stderr.on("data", function (data) {
            console.log("runExec ==> stderr: " + data);
            stderrCB(data);
        });
        // 退出之后的输出
        workerProcess.on("close", function (code) {
            console.log("out code：" + code);
            closeCB(code);
        });
    }

    deleteLocalConfig(projectList) {
        console.log("ios - deleteLocalConfig - ");
        let projectMap = JSON.parse(getStorage("projectMap-pluginIos") || "{}");
        let keyList = Object.keys(projectMap);
        let obj = (projectList || [])
            .filter((item) => keyList.includes(`${item.id}`))
            .map((item) => item.id);
        keyList.forEach((item) => {
            if (!obj.includes(Number(item))) {
                delete projectMap[item];
            }
        });
        setStorage("projectMap-pluginIos", JSON.stringify(projectMap));
    }
}

export default new IosBrigeImpl().getInstance();
