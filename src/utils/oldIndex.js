const fs = require("fs");
const path = require("path");

let ERRORCOD = {
    DIRERROR: "101", // 文件路径错误
    DIREXISTS: "102", // 文件插件内容存在
    SUCCESS: "200", // 文件插件内容存在
};

function errorFun(name, url, error, code, data = {}) {
    let dirError = {
        name: "",
        url: "",
        code: "",
        error: "",
        data: {},
    };
    dirError.name = name;
    dirError.url = url;
    dirError.code = code;
    dirError.error = error;
    dirError.data = data;
    return dirError;
}
module.exports = function editDir(data) {
    let { url, ip } = data;
    return new Promise((reslove, reject) => {
        let apiUrl = url + "/src/lib/common/Net.js";
        let scpMockUrl = url + "/src/lib/common/ScpMock.js";
        let jsBridgeUrl = url + "/src/lib/common/SnJsBridge.js";
        // 获取 Api 文件数据
        let ApiData = "";
        let jsBridgeData = "";
        try {
            ApiData = fs.readFileSync(apiUrl).toString().split("\n");
        } catch (error) {
            console.log("error=====> @@ src/utils/oldIndex.js ApiData @@", error);
            let err = errorFun("Net.js", apiUrl, error, ERRORCOD.DIRERROR);
            reject(err);
            return;
        }

        try {
            // 获取 jsBridge 文件数据
            jsBridgeData = fs.readFileSync(jsBridgeUrl).toString().split("\n");
        } catch (error) {
            console.log("error=====> @@ src/utils/oldIndex.js jsBridgeData @@", error);
            let err = errorFun("SnJsBridge.js", jsBridgeUrl, error, ERRORCOD.DIRERROR);
            reject(err);
            return;
        }

        let pluginContent = "";

        try {
            // 基础插件数据
            pluginContent = fs
                .readFileSync(path.join(__dirname, "./js/oldPluginContent.js"))
                .toString()
                .split("\n");
        } catch (error) {
            console.log("error=====> @@ src/utils/index.js jsBridgeData @@", error);
            let err = errorFun("jsBridgeUtils.js", jsBridgeUrl, error, ERRORCOD.DIRERROR);
            reject(err);
            return;
        }
        const pluginData = getPluginData();

        function pluginExists() {
            let exiDir = [];
            ApiData.forEach((item) => {
                if (item.indexOf(pluginData.IMPORT[2]) != -1) {
                    exiDir.push("Net.js");
                }
            });
            jsBridgeData.forEach((item) => {
                if (item.indexOf(pluginData.SCPMOCKFUN[13]) != -1) {
                    console.log('pluginData.SCPMOCKFUN[13]',pluginData.SCPMOCKFUN[13])
                    exiDir.push("SnJsBridge.js");
                }
            });
            return exiDir;
        }

        // 获取基础插件数据
        function getPluginData() {
            let arr = [];
            let data = {};
            pluginContent.forEach((item) => {
                if (item.indexOf("DIVIDER") != -1) {
                    let name = item.split("-")[0];
                    data[`${name}`] = arr;
                    arr = [];
                } else {
                    arr.push(item);
                }
            });
            return data;
        }

        // 在 Net.js 文件内插入 插件代码
        function setData(data) {
            let i = 0;
            data = data.map(item=>item+'\r')
            data.forEach((item, index) => {
                // 判断是否为空格区域
                if (item == "\r" && data[Number(index + 1)] !== "\r") {
                    i++;
                    // 在第一个空格区域插入 上方引入
                    if (i == 1) {
                        data.splice(index, 0, ...pluginData.IMPORT);
                    }
                }
                // 在 dealResultPromise 函数内 插入mock请求分支
                if (item.indexOf("export function doPost(") != -1) {
                    data.splice(Number(index + 1), 0, ...pluginData.MOCKBRANCH);
                }
            });
            return data;
        }

        // 数组拼接成字符串
        function getRealData(data) {
            return data.reduce((pre, cur) => {
                return pre + cur;
            }, "");
        }
        function editIpPort() {
            // 获取 Api 文件数据
            let ApiData = "";
            try {
                ApiData = fs.readFileSync(apiUrl).toString().split("\r");
            } catch (error) {
                console.log("error=====> @@ src/utils/index.js editIpPort @@", error);
                let err = errorFun("Net.js", apiUrl, error, ERRORCOD.DIRERROR);
                reject(err);
                return;
            }

            ApiData = ApiData.map((item) => {
                if (item.indexOf("urlApi") != -1 && item.indexOf("http") != -1) {
                    let before = item.split("://")[0];
                    return `${before}://${ip}/"`;
                }
                return item;
            }).join("\r");
            fs.writeFileSync(apiUrl, ApiData, "utf-8");
        }

        // 主函数
        function main() {
            let flag = true;
            try {
                let exiDir = pluginExists();
                let resData = {
                    scpMockUrl: scpMockUrl,
                };
                if (exiDir.length) {
                    flag = false;
                    editIpPort();
                    let errorName = exiDir.reduce((pre, cur) => {
                        return cur + "、" + pre;
                    }, "");
                    let err = errorFun(errorName, "", "", ERRORCOD.DIREXISTS, resData);
                    reslove(err);
                    return;
                }
                // 插入插件数据
                ApiData = setData(ApiData);
                console.log('ApiData',ApiData)
                // 进行字符串转化
                let resApiData = getRealData(ApiData);
                // 在 jsBridge 文件最后 插入scpMockFunction
                jsBridgeData = jsBridgeData.concat(...pluginData.SCPMOCKFUN);
                // 进行字符串转化
                let resJsBridgeData = getRealData(jsBridgeData);
                // 生成文件
                fs.writeFileSync(jsBridgeUrl, resJsBridgeData, "utf-8");
                fs.writeFileSync(apiUrl, resApiData, "utf-8");
                flag && editIpPort();
                fs.writeFileSync(scpMockUrl, pluginData.SCPMOCKURL.join("\n"), "utf-8");
                let suc = errorFun("Net.js、SnJsBridge.js", "", "", ERRORCOD.SUCCESS, resData);
                reslove(suc);
                return;
            } catch (error) {
                let err = errorFun("", "", "", ERRORCOD.DIRERROR, error);
                reject(err);
                return;
            }
        }

        main();
    });
};
