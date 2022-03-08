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
        // let apiUrl = url + "/src/service/Api.ts";
        let scpMockUrl = url + "/src/service/ScpMock.ts";
        // let jsBridgeUrl = url + "/src/utils/jsBridgeUtils.js";
        let commonUtilsUrl = url + "/src/utils/commonUtil.js";
        let mineApiUrl = url + "/bankConfig/getAccessToken/mineApi.js";
        let adapterUrl = url + "/src/lib/netAdapter/index.js";
        let BankJSBridgeUrl = url + "/bankConfig/getAccessToken/BankJSBridgeImpl.js";
        // // 获取 Api 文件数据
        // let ApiData = "";
        // try {
        //     ApiData = fs.readFileSync(apiUrl).toString().split("\n");
        // } catch (error) {
        //     console.log("error=====> @@ src/utils/index.js ApiData @@", error);
        //     let err = errorFun("Api.ts", apiUrl, error, ERRORCOD.DIRERROR);
        //     reject(err);
        //     return;
        // }

        // 获取 adapter 文件数据
        let adapterData = "";
        try {
            adapterData = fs.readFileSync(adapterUrl).toString().split("\n");
        } catch (error) {
            console.log("error=====> @@ /src/lib/netAdapter/index.js adapterData @@", error);
            let err = errorFun("adapter.ts", adapterUrl, error, ERRORCOD.DIRERROR);
            reject(err);
            return;
        }

        // let jsBridgeData = "";
        // try {
        //     // 获取 jsBridge 文件数据
        //     jsBridgeData = fs.readFileSync(jsBridgeUrl).toString().split("\n");
        // } catch (error) {
        //     console.log("error=====> @@ src/utils/index.js jsBridgeData @@", error);
        //     let err = errorFun("jsBridgeUtils.js", jsBridgeUrl, error, ERRORCOD.DIRERROR);
        //     reject(err);
        //     return;
        // }

        let commonUtilsData = "";
        try {
            console.log("commonUtilsUrl", commonUtilsUrl);
            // 获取  文件数据
            commonUtilsData = fs.readFileSync(commonUtilsUrl).toString().split("\n");
        } catch (error) {
            console.log("error=====> @@ src/utils/index.js commonUtilsData @@", error);
            let err = errorFun("commonUtils.js", commonUtilsUrl, error, ERRORCOD.DIRERROR);
            reject(err);
            return;
        }

        let mineApiData = "";
        try {
            console.log("mineApiUrl", mineApiUrl);
            // 获取 jsBridge 文件数据
            mineApiData = fs.readFileSync(mineApiUrl).toString().split("\n");
        } catch (error) {
            console.log("error=====> @@ /bankConfig/getAccessToken/mineApi.js mineApiData @@", error);
            let err = errorFun("mineApi.js", mineApiUrl, error, ERRORCOD.DIRERROR);
            reject(err);
            return;
        }

        let BankJSBridgeData = "";
        try {
            console.log("mineApiUrl", BankJSBridgeUrl);
            // 获取 jsBridge 文件数据
            BankJSBridgeData = fs.readFileSync(BankJSBridgeUrl).toString().split("\n");
        } catch (error) {
            console.log("error=====> @@ /bankConfig/getAccessToken/BankJSBridge.js BankJSBridge @@", error);
            let err = errorFun("BankJSBridge.js", BankJSBridgeUrl, error, ERRORCOD.DIRERROR);
            reject(err);
            return;
        }

        let pluginContent = "";

        try {
            // 基础插件数据
            pluginContent = fs
                // .readFileSync(path.resolve("./src/utils/pluginContent.js"))
                .readFileSync(path.join(__dirname, "./js/pluginContent.js"))
                .toString()
                .split("\n");
        } catch (error) {
            console.log("error=====> @@ src/utils/index.js pluginContent @@", error);
            let err = errorFun(
                "pluginContent.js",
                "./js/pluginContent.js",
                error,
                ERRORCOD.DIRERROR,
            );
            reject(err);
            return;
        }
        const pluginData = getPluginData();

        function pluginExists() {
            let exiDir = [];
            // ApiData.forEach((item) => {
            //     if (item.indexOf(pluginData.IMPORT[2]) != -1) {
            //         exiDir.push("Api.ts");
            //     }
            // });
            // jsBridgeData.forEach((item) => {
            //     if (item.indexOf(pluginData.SCPMOCKFUN[13]) != -1) {
            //         exiDir.push("jsBridgeUtils.js");
            //     }
            // });
            // console.log("pluginData.COMMONUTILS", pluginData.COMMONUTILS);
            commonUtilsData.forEach((item) => {
                if (item.indexOf(pluginData.COMMONUTILS[2]) != -1) {
                    exiDir.push("commonUtils.js");
                }
            });
            mineApiData.forEach((item) => {
                if (item.indexOf(pluginData.NETMINEAPIONE[2]) != -1) {
                    exiDir.push("mineApi.ts");
                }
            });
            adapterData.forEach((item) => {
                if (item.indexOf(pluginData.NETADAPTER[3]) != -1) {
                    exiDir.push("mineApi.ts");
                }
            });
            BankJSBridgeData.forEach((item) => {
                if (item.indexOf(pluginData.BANKJSBRADGETWO[5]) != -1) {
                    exiDir.push("BankJSBridgeImpl.js");
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

        // 在 Api.ts 文件内插入 插件代码
        // function setData(data) {
        // 	let i = 0;
        // 	data.forEach((item, index) => {
        // 		// 判断是否为空格区域
        // 		if (item == "\r" && data[Number(index + 1)] !== "\r") {
        // 			i++;
        // 			// 在第二个空格区域插入 上方引入
        // 			if (i == 2) {
        // 				data.splice(index, 0, ...pluginData.IMPORT);
        // 			}
        // 		}
        // 		// 在 dealResultPromise 函数内 插入mock请求分支
        // 		if (item.indexOf("dealResultPromise") != -1) {
        // 			data.splice(Number(index + 2), 0, ...pluginData.MOCKBRANCH);
        // 		}
        // 	});
        // 	return data;
        // }
        function setMineApiData(data) {
            let flag = true;
            data.splice(0, 0, ...pluginData.NETMINEAPIONE);
            data.forEach((item, index) => {
                if (item.indexOf("async getRequsetInfo") != -1) {
                    flag = false;
                    data.splice(Number(index + 1), 0, ...pluginData.NETMINEAPITWO);
                }
            });
            flag && data.forEach((item,index)=>{
                if(item.indexOf("extends") != -1){
                    data.splice(Number(index + 1), 0, ...pluginData.NETMINEAPITHREE);
                }
            })
            return data.map((item) => {
                if (item.indexOf("\r") != -1) {
                    return item;
                }
                return `${item}\r`;
            });
        }
        function setBankJSBridgeData(data) {
            let flag = true;
            data.splice(0, 0, ...pluginData.BANKJSBRADGEONE);
            data.forEach((item, index) => {
                if (item.indexOf("async GetLocationAccesstion") != -1 && flag) {
                    flag = false;
                    data.splice(Number(index), 1, ...pluginData.BANKJSBRADGETWO);
                }
            });
            flag && data.forEach((item,index)=>{
                if(item.indexOf("extends") != -1){
                    data.splice(Number(index + 1), 0, ...pluginData.BANKJSBRADGETHREE);
                }
            })
            return data.map((item) => {
                if (item.indexOf("\r") != -1) {
                    return item;
                }
                return `${item}\r`;
            });
        }
        function setCommonUtilsData(data) {
            data = data.map((item) => {
                if (item.indexOf("\r") != -1) {
                    return item;
                }
                return `${item}\r`;
            });
            return data.concat(...pluginData.COMMONUTILS);
        }

        function setAdapterData(data) {
            data.forEach((item, index) => {
                // 在 dealResultPromise 函数内 插入mock请求分支
                if (item.indexOf("export") != -1) {
                    data.splice(Number(index - 1), 0, ...pluginData.NETADAPTER);
                }
            });
            let type = false
            data = data.map((item, index) => {
                if (item.indexOf("export") != -1 && item.indexOf("NetApi") != -1) {
                    item = item.replace("NetApi", "MockNetApi as NetApi");
                }
                if (item.indexOf("export") != -1 && item.indexOf("NetApi") == -1) {
                    type = true
                }
                if(type) {
                    item = item.replace("NetApi", "MockNetApi as NetApi");
                }
                return item;
            });

            return data.map((item) => {
                if (item.indexOf("\r") != -1) {
                    return item;
                }
                return `${item}\r`;
            });
        }

        // 数组拼接成字符串
        function getRealData(data) {
            return data.reduce((pre, cur) => {
                return pre + cur;
            }, "");
        }
        // function editIpPort() {
        //     // 获取 Api 文件数据
        //     let ApiData = "";
        //     try {
        //         ApiData = fs.readFileSync(apiUrl).toString().split("\r");
        //     } catch (error) {
        //         console.log("error=====> @@ src/utils/index.js ApiData @@", error);
        //         let err = errorFun("Api.ts", apiUrl, error, ERRORCOD.DIRERROR);
        //         reject(err);
        //         return;
        //     }

        //     ApiData = ApiData.map((item) => {
        //         if (item.indexOf("urlApi") != -1 && item.indexOf("http") != -1) {
        //             let before = item.split("://")[0];
        //             return `${before}://${ip}/'`;
        //         }
        //         return item;
        //     }).join("\r");
        //     fs.writeFileSync(apiUrl, ApiData, "utf-8");
        // }
        function editIpPort() {
            // 获取 adapter 文件数据
            let editAdapterData = "";
            try {
                editAdapterData = fs.readFileSync(adapterUrl).toString().split("\r");
            } catch (error) {
                console.log("error=====> @@ src/lib/netAdapter/index.js editAdapterData @@", error);
                let err = errorFun("netAdapter/index.js", adapterUrl, error, ERRORCOD.DIRERROR);
                reject(err);
                return;
            }

            editAdapterData = editAdapterData.map((item) => {
                if (item.indexOf("urlApi") != -1 && item.indexOf("http") != -1) {
                    let before = item.split("://")[0];
                    return `${before}://${ip}/"`;
                }
                return item;
            }).join("\r");
            fs.writeFileSync(adapterUrl, editAdapterData, "utf-8");
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
                // ApiData = setData(ApiData);
                mineApiData = setMineApiData(mineApiData);
                adapterData = setAdapterData(adapterData);
                commonUtilsData = setCommonUtilsData(commonUtilsData);
                BankJSBridgeData = setBankJSBridgeData(BankJSBridgeData);
                // 进行字符串转化
                // let resApiData = getRealData(ApiData);
                let resMineApiData = getRealData(mineApiData);
                let resAdapterData = getRealData(adapterData);
                let resCommonUtilsData = getRealData(commonUtilsData);
                let resBankJSBridgeData = getRealData(BankJSBridgeData);
                // 生成文件
                // fs.writeFileSync(jsBridgeUrl, resJsBridgeData, "utf-8");
                // fs.writeFileSync(apiUrl, resApiData, "utf-8");
                fs.writeFileSync(mineApiUrl, resMineApiData, "utf-8");
                fs.writeFileSync(adapterUrl, resAdapterData, "utf-8");
                fs.writeFileSync(commonUtilsUrl, resCommonUtilsData, "utf-8");
                fs.writeFileSync(BankJSBridgeUrl, resBankJSBridgeData, "utf-8");
                flag && editIpPort();
                fs.writeFileSync(scpMockUrl, pluginData.SCPMOCKURL.join("\n"), "utf-8");
                let suc = errorFun("Api.ts、jsBridgeUtils.js", "", "", ERRORCOD.SUCCESS, resData);
                reslove(suc);
                return;
            } catch (error) {
                console.log("error=====> @@ src/utils/index.js pluginContent @@", error);
                let err = errorFun("", "", "", ERRORCOD.DIRERROR, error);
                reject(err);
                return;
            }
        }

        main();
    });
};
