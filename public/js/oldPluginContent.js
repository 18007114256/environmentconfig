
//ScpMock 挡板数据接口
import { ScpMockUrl } from "./ScpMock.js";
import { GetScpMockFunction } from "./SnJsBridge.js";
import axios from "axios";
import qs from "qs";

const SCPMOCKURL = ScpMockUrl;
const urlApi = "http://10.2.30.231/";
const scpmock = "scpmock";
const axiosMock = true;
IMPORT-DIVIDER;

    //TODO 处理 SCPMOCK 数据 发布生产可以注释掉
    url = url.replace("../", "");
    if (SCPMOCKURL.includes(url)) {
        return new Promise((res, rej) => {
            const urlApiMock = `${urlApi}~${scpmock}`;
            const requestName = `/${url}`;
            const datas = {
                params: JSON.stringify(data),
                Url: {
                    urlApi: urlApiMock,
                    cmd: requestName, //请求接口名
                },
            };
            if (axiosMock) {
                axios({
                    method: "post",
                    url: `${urlApiMock}${requestName}`,
                    data: qs.stringify(data),
                }).then((Response) => {
                    return res(Response['result']);
                });
            } else {
                GetScpMockFunction(datas)
                    .then((Response) => {
                        res(JSON.parse(Response.data)['result']);
                    })
                    .catch((Response) => {
                        return rej(Response);
                    });
            }
        });
    }

MOCKBRANCH-DIVIDER;

/**
 * 通过APP调用ApiFkaer挡板数据，返回到前端
 * 参数格式
 *  data = {
 *		params: { userId: "123" }, //请求参数
 *	    url: {
 *          urlApi: "http://10.2.30.130:8081/",  //请求url
 *          cmd: "get_list"  //请求接口名
 *       }
 *	};
 * @export
 */
export function GetScpMockFunction(data = {}) {
    return callHandler("GetApiFakerFunction", data);
}

SCPMOCKFUN-DIVIDER;
// 获取环境变量
const nodeEnv = process.env["NODE_ENV"];
// 需要 ScpMock数据 接口列表
let ScpMockUrl = [
];

if (nodeEnv !== "development") {
    ScpMockUrl = [];
}

export { ScpMockUrl };
SCPMOCKURL-DIVIDER;
