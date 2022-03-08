<template>
    <div class="money">
        <h1>json2csv</h1>
        <div class="contentBox">
            <div class="dropwrap" ref="dropwrap">
                支持拖拽区域
                <div class="addImg" @click="addImg">
                    +
                </div>
            </div>
            <!-- <div class="showBox">
                <div>展示区域</div>
                <div id="img-perv-div"></div>
            </div> -->
        </div>
    </div>
</template>
<script>
// const { ipcRenderer: ipc } = window.require('electron')
// import DownLoadHandler from './DownLoadHandler.js';
const dialog = window.require("electron").remote.dialog;
const fs = window.require("fs");
/**
 * 渲染进程
 */
export default {
    data() {
        return {
            resArr: "",
        };
    },
    mounted() {
        this.dropFun();
    },
    methods: {
        dropFun() {
            let _this = this;
            let dropwrapper = this.$refs.dropwrap;
            dropwrapper.addEventListener("drop", (e) => {
                e.preventDefault();
                const files = e.dataTransfer.files;
                if (files) {
                    _this.upLoadFun1(files[0].path);
                }
            });
            dropwrapper.addEventListener("dragover", (e) => {
                e.preventDefault();
            });
        },
        addImg() {
            let _this = this;
            dialog
                .showOpenDialog({
                    title: "请选择json",
                })
                .then((res) => {
                    if (!res.canceled) {
                        let _img_src = res.filePaths[0];
                        _this.upLoadFun1(_img_src);
                    }
                })
                .catch((req) => {
                    console.log(req);
                });
        },
        upLoadFun1(url) {
            const content = fs.readFileSync(url, "utf-8");
            let data = JSON.parse(content).data;
            let newData = [];
            data.forEach((item) => {
                let obj = {
                    app_desc: "",
                    app_id: "",
                    version: "",
                    srcTpy: "1",
                    android: "0.0.1-",
                    ios: "0.0.1-",
                    main_url: "",
                    extend_info: "",
                    installType: "1",
                    auto_install: "1",
                };
                for (let key in obj) {
                    if (item[key] != undefined && key != "extend_info") {
                        obj[key] = item[key];
                    }
                }
                newData.push(obj);
            });
            this.downloadJSON2CSV(newData);
        },
        downloadJSON2CSV(objArray) {
            var array =
                typeof objArray != "object" ? JSON.parse(objArray) : objArray;
            var str = "";
            let title =
                `名称,h5Id,版本号,资源包类型(全局资源包：0，普通资源包：1),Android版本范围,IOS版本范围,主入口 URL,扩展信息,下载时机(0:仅WIFI，1:所有网络都下载),安装时机(0:不预加载，1:预加载)` +
                "\r";
            for (var i = 0; i < array.length; i++) {
                var line = ``;
                for (var index in array[i]) {
                    line += `${JSON.stringify(array[i][index])},`;
                }
                str += line.slice(0, line.length - 1) + "\r";
            }
            str = title + str;
            let blob = new Blob([str]);
            var a = window.document.createElement("a");
            a.href = window.URL.createObjectURL(blob, {
                type: "text/plain",
            });
            a.download = "updata.csv";
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
        },
        getDomById(id) {
            return document.getElementById(id);
        },
    },
};
</script>

<style lang='less'>
.money {
    width: 100%;
    height: 100%;
    overflow-y: scroll;
    .contentBox {
        display: flex;
        padding: 0 10px 20px;
        .dropwrap {
            height: 120px;
            width: 120px;
            border: 1px dashed #aaa;
            .addImg {
                word-break: break-all;
                font-size: 80px;
            }
        }
        .showBox {
            width: calc(100% - 150px);
            height: 100%;
            margin-left: 20px;
            border: 1px dashed #aaa;
            #img-perv-div {
                margin-top: 20px;
                width: 100%;
                overflow-x: scroll;
                min-height: 300px;
                background-color: #ccc;
                display: flex;
                align-items: center;
                justify-content: center;
            }
        }
    }
}
</style>