import { setStorage, getStorage } from "./commonUtils.js";
// import Datastore from "nedb";
// const Datastore = window.require("nedb");

const { ipcRenderer: ipc } = window.require("electron");

const fs = window.require("fs"); //获取文件系统模块，负责读写文件
const path = window.require("path");

let _this = null;
let _res = null;
let _rej = null;
class H5BrigeImpl {
    instance;
    projectMap = {};
    info;
    scpMockData = {};
    projectList = {};
    db = {};
    constructor() {
        this.projectMap =
            (getStorage("projectMap-pluginH5") && JSON.parse(getStorage("projectMap-pluginH5"))) ||
            {};
        this.projectList =
            (getStorage("projectList-pluginH5") &&
                JSON.parse(getStorage("projectList-pluginH5"))) ||
            {};
        this.scpMockData =
            (getStorage("scpMockData-pluginH5") &&
                JSON.parse(getStorage("scpMockData-pluginH5"))) ||
            {};
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
        _this = this;
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
                        return { name: item.name, checked: true };
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

    getInstance() {
        if (!this.instance) {
            this.instance = new H5BrigeImpl();
        }
        return this.instance;
    }
    checkEnv() {
        return new Promise((res) => {
            let obj = {
                type: true,
                code: 200,
                msg: "当前环境不支持，请按照操作手册安装环境",
            };
            res(obj);
        });
    }
    creatProject(info) {
        return new Promise((res, rej) => {
            _res = res;
            _rej = rej;
            console.log("H5 - creatProject - ", info);
            this.info = info;
            let basePath = info.basePath;
            let ip = info.ip;
            let product = info.product;
            let obj = {
                url: basePath,
                ip: ip,
                product: product,
            };
            this.upLoadFun(obj);
        });
    }
    getProject(id) {
        console.log("H5 - getProject - ", id);
        return this.projectMap[id];
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

    getProjectInfo() {
        console.log("H5 - getProjectInfo - ");
        let info = {
            interfaceList: JSON.parse(getStorage("projectMap-pluginH5") || "{}"),
        };
        return info;
    }

    setProjectInfo(info) {
        return new Promise((res, rej) => {
            _res = res;
            _rej = rej;
            console.log("H5 - setProjectInfo - ", info);
            this.setConfig(info);
        });
    }
    setConfig(info) {
        let interfaceList = info.interfaceList;
        let mockFlag = info.mockFlag;
        let id = info.id;
        let content = interfaceList
            .map((item) => {
                return `${mockFlag ? "" : "//"}${item.name}`;
            })
            .reduce((pre, cur) => {
                if (cur.indexOf("//") != -1) {
                    return pre + '\r//"' + cur.replace("//", "") + '"' + ",";
                } else {
                    return pre + '\r"' + cur + '"' + ",";
                }
            }, "");
        let resStr =
            this.scpMockData[id].start.join("\r") +
            content +
            "\r" +
            this.scpMockData[id].end.join("\r");
        fs.writeFileSync(this.scpMockData[id].url, resStr, "utf-8");
        _res(true);
    }

    upLoadFun(data) {
        let { url, ip, product } = data;
        _this = this;
        url = url.split("\\").join("/");
        let obj = {
            url: url,
            ip: ip,
            product: product,
        };
        ipc.send("editDir", obj);
        ipc.on("sendPlugin", this.edCallBack);
    }

    edCallBack(event, data) {
        _this.tosatMsg = data.msg;
        if (!data.type) return _rej(data);
        let scpMockUrl = data.data.scpMockUrl;
        _this.url = scpMockUrl;
        _this.scpMockData[_this.info.id] = {};
        _this.scpMockData[_this.info.id]["url"] = scpMockUrl;
        return _this.readFile(scpMockUrl);
    }

    readFile(url) {
        let data = fs.readFileSync(url).toString().split("\r");
        let start = 0;
        let end = 0;
        let flag = true;
        let scpData = [];
        data.forEach((item, index) => {
            scpData.push(item);
            if (item.indexOf("ScpMockUrl") != -1 && flag) {
                start = Number(index + 1);
                flag = false;
                _this.scpMockData[_this.info.id]["start"] = scpData;
                scpData = [];
            }
            if (item.indexOf("];") != -1 && data[Number(index + 1)] == "\n") {
                end = index;
                scpData = [];
                scpData.push(item);
            }
        });
        _this.scpMockData[_this.info.id]["end"] = scpData;
        _this.mockList = data
            .slice(start, end)
            .filter((item) => item != "\n")
            .map((item) => {
                return {
                    name: item.split('"')[1],
                    checked: true,
                };
            });
        _this.projectMap[_this.info.id] = _this.mockList;
        setStorage("projectMap-pluginH5", JSON.stringify(_this.projectMap));
        setStorage("scpMockData-pluginH5", JSON.stringify(_this.scpMockData));
        _res(_this.mockList);
        return _this.mockList;
    }

    deleteLocalConfig(projectList) {
        let projectMap = JSON.parse(getStorage("projectMap-pluginH5") || "{}");
        let scpMockData = JSON.parse(getStorage("scpMockData-pluginH5") || "{}");
        let keyList = Object.keys(projectMap);
        let obj = (projectList || [])
            .filter((item) => keyList.includes(`${item.id}`))
            .map((item) => item.id);
        keyList.forEach((item) => {
            if (!obj.includes(Number(item))) {
                delete projectMap[item];
                delete scpMockData[item];
            }
        });
        setStorage("projectMap-pluginH5", JSON.stringify(projectMap));
        setStorage("scpMockData-pluginH5", JSON.stringify(scpMockData));
    }
}
export default new H5BrigeImpl().getInstance();
