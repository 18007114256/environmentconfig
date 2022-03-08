
//ScpMock 挡板数据接口
import { ScpMockUrl } from './ScpMock';
import { setWaterMark, scpmockBranch } from '../utils/commonUtil';
import { GetScpMockFunction } from "../utils/jsBridgeUtils.js";
import axios from 'axios'
import qs from 'qs'

const SCPMOCKURL = ScpMockUrl;
const urlApi = 'http://10.2.30.231/'
const version = 'v1'
const scpmock = 'scpmock'
const axiosMock = true
IMPORT-DIVIDER

            //TODO 处理 SCPMOCK 数据 发布生产可以注释掉
			if (scpmockBranch(url, SCPMOCKURL)) {
				const urlApiMock = `${urlApi}~${scpmock}`;
				const requestName = `${url.split(version)[1]}`;
				const data = {
					params: JSON.stringify(params),
					Url: {
						urlApi: urlApiMock,
						cmd: requestName //请求接口名
					}
				};
				if (axiosMock) {
                    setWaterMark(requestName)
					axios({
						method: "post",
						url: `${urlApiMock}${requestName}`,
						data: qs.stringify(params)
					}).then(Response => {
                        if(`${Response.data}` === 'null'){
                            const obj1 = {code:404,msg:'访问接口不存在'}
                            alert(`code：${obj1.code}\nurl：${requestName}\nmsg：${obj1.msg}`)
                            res(obj1)
                        }else{
                            res(Response["result"]);
                        }
					})
                    .catch(Response => {
                        console.log('Response', Response)
                        const obj2 = {code:400,msg:'当前网络无法访问mock服务,或mock服务没有运行'}
                        alert(`code：${obj2.code}\nurl：${requestName}\nmsg：${obj2.msg}`)
                            res(obj2);
                    });;
					return;
				} else {
					GetScpMockFunction(data)
						.then(Response => {
							res(JSON.parse(Response.data)["result"]);
						})
						.catch(Response => {
							rej(Response);
						});
					return;
				}
			}
            
MOCKBRANCH-DIVIDER

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
    return BrowserApi.callHandler('GetApiFakerFunction', data);
}

SCPMOCKFUN-DIVIDER
// 获取环境变量
const nodeEnv = process.env["NODE_ENV"]
// 需要 ScpMock数据 接口列表
let ScpMockUrl: any[] = [
    "/ebank/test/v1/testInterface",
];

if (nodeEnv !== "development") {
    ScpMockUrl = [];
}

export { ScpMockUrl };
SCPMOCKURL-DIVIDER


export function setWaterMark() {
	let content = '正在访问挡板数据'
	//调用方法
	hasWaterMark() ? '' : watermark({"watermark_txt": content});
}

function hasWaterMark(){
	return document.querySelector('.mask_div') != null
}

function watermark(settings) {
	//默认设置
	var defaultSettings={
		watermarl_element:"body",
		watermark_txt:"",
		watermark_x:20,//水印起始位置x轴坐标
		watermark_y:20,//水印起始位置Y轴坐标
		watermark_rows:2000,//水印行数
		watermark_cols:2000,//水印列数
		watermark_x_space:70,//水印x轴间隔
		watermark_y_space:30,//水印y轴间隔
		watermark_color:'#aaa',//水印字体颜色
		watermark_alpha:0.4,//水印透明度
		watermark_fontsize:'15px',//水印字体大小
		watermark_font:'微软雅黑',//水印字体
		watermark_width:70,//水印宽度
		watermark_height:80,//水印长度
		watermark_angle:30//水印倾斜度数
	};
	
	//采用配置项替换默认值，作用类似jquery.extend
	if(arguments.length===1&&typeof arguments[0] ==="object" )
	{
		var src=arguments[0]||{};
		for(let key in src)
		{
			if(src[key]&&defaultSettings[key]&&src[key]===defaultSettings[key])
				continue;
			else if(src[key])
				defaultSettings[key]=src[key];
		}
	}

	var oTemp = document.createDocumentFragment();


	var maskElement=document.getElementById(defaultSettings.watermarl_element)||document.body;

	//获取页面最大宽度
	var page_width = Math.max(maskElement.scrollWidth,maskElement.clientWidth);

	//获取页面最大高度
	var page_height = Math.max(maskElement.scrollHeight,maskElement.clientHeight);


	defaultSettings.watermark_width = page_width / 3

	//水印数量自适应元素区域尺寸
	defaultSettings.watermark_cols=Math.ceil(page_width/(defaultSettings.watermark_x_space+defaultSettings.watermark_width));
	defaultSettings.watermark_rows=Math.ceil(page_height/(defaultSettings.watermark_y_space+defaultSettings.watermark_height));
	var x;
	var y;
	for (var i = 0; i < defaultSettings.watermark_rows; i++) {
		y = defaultSettings.watermark_y + (defaultSettings.watermark_y_space + defaultSettings.watermark_height) * i;
		for (var j = 0; j < defaultSettings.watermark_cols; j++) {
			x = defaultSettings.watermark_x + (defaultSettings.watermark_width + defaultSettings.watermark_x_space) * j;
			var mask_div = document.createElement('div');
			mask_div.id = 'mask_div' + i + j;
			mask_div.className = 'mask_div';
			mask_div.appendChild(document.createTextNode(defaultSettings.watermark_txt));
			mask_div.innerHTML=(defaultSettings.watermark_txt);
			//设置水印div倾斜显示
			mask_div.style.webkitTransform = "rotate(-" + defaultSettings.watermark_angle + "deg)";
			mask_div.style.MozTransform = "rotate(-" + defaultSettings.watermark_angle + "deg)";
			mask_div.style.msTransform = "rotate(-" + defaultSettings.watermark_angle + "deg)";
			mask_div.style.OTransform = "rotate(-" + defaultSettings.watermark_angle + "deg)";
			mask_div.style.transform = "rotate(-" + defaultSettings.watermark_angle + "deg)";
			mask_div.style.visibility = "";
			mask_div.style.position = "absolute";
			mask_div.style.left = x + 'px';
			mask_div.style.top = y + 'px';
			mask_div.style.overflow = "hidden";
			mask_div.style.zIndex = "9999";
			mask_div.style.pointerEvents='none';//pointer-events:none  让水印不遮挡页面的点击事件
			//mask_div.style.border="solid #eee 1px";　　　　　　　　　　//兼容IE9以下的透明度设置
			mask_div.style.filter="alpha(opacity=50)";
			mask_div.style.opacity = defaultSettings.watermark_alpha;
			mask_div.style.fontSize = defaultSettings.watermark_fontsize;
			mask_div.style.fontFamily = defaultSettings.watermark_font;
			mask_div.style.color = defaultSettings.watermark_color;
			mask_div.style.textAlign = "center";
			mask_div.style.width = defaultSettings.watermark_width + 'px';
			mask_div.style.height = defaultSettings.watermark_height + 'px';
			mask_div.style.display = "block";
			oTemp.appendChild(mask_div);
		};
	};
	maskElement.appendChild(oTemp);
}  

export function scpMockBranch(url, arr){
    let flag = false;
    arr.forEach(item=>{
        if(url.includes(item)){
            flag = true
        }
    })
    return flag;
}

COMMONUTILS-DIVIDER  

import { NetApi } from '@/lib/netAdapter/index';
import { ScpMockUrl as SCPMOCKURL } from "@/service/ScpMock";
import { scpMockBranch } from '@/utils/commonUtil';

NETMINEAPIONE-DIVIDER  

		let url = '/ebank/Keycloak/v1/getRequsetInfo';
		let type = 'Get';
		let paramsData = {};
		let needLogin = false;
		if(scpMockBranch(url, SCPMOCKURL)){
			let resData = await new NetApi()[`do${type}`](url, paramsData, needLogin);
			return resData.result;
		}

NETMINEAPITWO-DIVIDER  

	async getRequsetInfo(params) {
		let url = '/ebank/Keycloak/v1/getRequsetInfo';
		let type = 'Get';
		let paramsData = {};
		let needLogin = false;
		if(scpMockBranch(url, SCPMOCKURL)){
			let resData = await new NetApi()[`do${type}`](url, paramsData, needLogin);
			return resData.result;
		}
		return super.getRequsetInfo(params);
	}

NETMINEAPITHREE-DIVIDER  

import axios from "axios";
import qs from "qs";
import { ScpMockUrl as SCPMOCKURL } from "@/service/ScpMock";
import { setWaterMark, scpMockBranch } from "@/utils/commonUtil";

const urlApi = "http://10.2.25.159:82/";
const version = "v1";
const scpmock = "scpmock";

class MockNetApi extends NetApi {
	doGet(url, params, needLogin = true) {
		return new Promise(async (res, rej) => {
			//TODO 处理 SCPMOCK 数据 发布生产可以注释掉
			if (scpMockBranch(url, SCPMOCKURL)) {
				this.doMock(url, params, (needLogin = true), res, rej);
				return;
			}
			super
				.doGet(url, params, (needLogin = true))
				.then(async (resData) => {
					console.log("ailong doGet", url, resData);
					res(resData);
				})
				.catch((error) => {
					rej(error);
				});
		});
	}

	doPost(url, params, needLogin = true) {
		return new Promise(async (res, rej) => {
			//TODO 处理 SCPMOCK 数据 发布生产可以注释掉
			if (scpMockBranch(url, SCPMOCKURL)) {
				this.doMock(url, params, (needLogin = true), res, rej);
				return;
			}
			super
				.doPost(url, params, (needLogin = true))
				.then(async (resData) => {
					console.log("ailong dopost", url, resData);
					res(resData);
				})
				.catch((error) => {
					rej(error);
				});
		});
	}

	doMock(url, params, needLogin = true, res = null, rej = null) {
		return new Promise((mres, mrej) => {
			const urlApiMock = `${urlApi}~${scpmock}`;
			const requestName = `${url.split(version)[1]}`;
			const data = {
				params: JSON.stringify(params),
				Url: {
					urlApi: urlApiMock,
					cmd: requestName, //请求接口名
				},
			};
			setWaterMark(requestName)
			axios({
				method: "post",
				url: `${urlApiMock}${requestName}`,
				data: qs.stringify(params),
			})
				.then((Response) => {
					if (`${Response.data}` === "null") {
						const obj1 = { code: 404, msg: "访问接口不存在" };
						alert(
							`code：${obj1.code}\nurl：${requestName}\nmsg：${obj1.msg}`
						);
						res == null ? mres(obj1) : res(obj1);
						return;
					} else {
						Response.request = {
                            url: `${urlApiMock}${requestName}`,
                            reqParams: params
                        };
						Response.isSuccess = () => {
							return Response.resultCode == 0;
						};
						res == null ? mres(Response) : res(Response);
						return;
					}
				})
				.catch((Response) => {
					console.log("Response", Response);
					const obj2 = {
						code: 400,
						msg: "当前网络无法访问mock服务,或mock服务没有运行",
					};
					alert(
						`code：${obj2.code}\nurl：${requestName}\nmsg：${obj2.msg}`
					);
					res == null ? mres(obj2) : res(obj2);
					return;
				});
		});
	}
}


NETADAPTER-DIVIDER  

import { NetApi } from '@/lib/netAdapter/index';
import { ScpMockUrl as SCPMOCKURL } from "@/service/ScpMock";
import { scpMockBranch } from '@/utils/commonUtil';

BANKJSBRADGEONE-DIVIDER
		//从APP获取token
	async GetTokenFromApp() {
		let url = '/ebank/Keycloak/v1/GetLocationAccesstion';
		let type = 'Get';
		let paramsData = {};
		let needLogin = false;
		if(scpMockBranch(url, SCPMOCKURL)){
			let resData = await new NetApi()[`do${type}`](url, paramsData, needLogin);
			let localKeyCloak = resData.result.localKeyCloak;
			return JSON.stringify(localKeyCloak) 
		}
		return super.GetTokenFromApp();
	}
	
	async GetLocationAccesstion(forceUpdate) {

		let url = '/ebank/Keycloak/v1/GetLocationAccesstion';
		let type = 'Get';
		let paramsData = {};
		let needLogin = false;
		if(scpMockBranch(url, SCPMOCKURL)){
			let resData = await new NetApi()[`do${type}`](url, paramsData, needLogin);
			let localKeyCloak = resData.result.localKeyCloak;
			return localKeyCloak.token
		}

BANKJSBRADGETWO-DIVIDER
	//从APP获取token
	async GetTokenFromApp() {
		let url = '/ebank/Keycloak/v1/GetLocationAccesstion';
		let type = 'Get';
		let paramsData = {};
		let needLogin = false;
		if(scpMockBranch(url, SCPMOCKURL)){
			let resData = await new NetApi()[`do${type}`](url, paramsData, needLogin);
			let localKeyCloak = resData.result.localKeyCloak;
			return JSON.stringify(localKeyCloak) 
		}
		return super.GetTokenFromApp();
	}

	async GetLocationAccesstion(forceUpdate) {
		let url = '/ebank/Keycloak/v1/GetLocationAccesstion';
		let type = 'Get';
		let paramsData = {};
		let needLogin = false;
		if(scpMockBranch(url, SCPMOCKURL)){
			let resData = await new NetApi()[`do${type}`](url, paramsData, needLogin);
			let localKeyCloak = resData.result.localKeyCloak;
			return localKeyCloak.token
		}
		return super.GetLocationAccesstion(forceUpdate);
	}

BANKJSBRADGETHREE-DIVIDER