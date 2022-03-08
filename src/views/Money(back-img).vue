<template>
    <div class="money">
        <h1>钱包页内容</h1>
        <div class="contentBox">
            <div class="dropwrap" ref="dropwrap">
                支持拖拽区域
                <div class="addImg" @click="addImg">
                    +
                </div>
            </div>
            <div class="showBox">
                <div>展示区域</div>
                <div id="img-perv-div"></div>
            </div>
        </div>
    </div>
</template>
<script>
// const { ipcRenderer: ipc } = window.require('electron')
import DownLoadHandler from './DownLoadHandler.js';
const dialog = window.require('electron').remote.dialog
const fs = window.require('fs')
const mineType = require('mime-types')
/**
 * 渲染进程
 */
export default {
    data() {
        return {
            resArr: '',
        }
    },
    mounted() {
        this.dropFun()
    },
    methods: {
        dropFun() {
            let _this = this
            let dropwrapper = this.$refs.dropwrap
            dropwrapper.addEventListener('drop', (e) => {
                e.preventDefault()
                const files = e.dataTransfer.files
                if (files) {
                    _this.upLoadFun(files[0].path)
                }
            })
            dropwrapper.addEventListener('dragover', (e) => {
                e.preventDefault()
            })
        },
        addImg() {
            let _this = this
            dialog
                .showOpenDialog({
                    title: '请选择图片',
                })
                .then((res) => {
                    if (!res.canceled) {
                        let _img_src = res.filePaths[0]
                        _this.upLoadFun(_img_src)
                    }
                })
                .catch((req) => {
                    console.log(req)
                })
        },
        upLoadFun(src) {
            let _this = this
            let extensions = DownLoadHandler.fileExtensionCheck(src)
            if (extensions == 'IMG') {
                let data = fs.readFileSync(src)
                data = new Buffer(data).toString('base64')
                let base64 = 'data:' + mineType.lookup(src) + ';base64,' + data
                //添加预览图片到容器框
                let img = document.createElement('img')
                img.setAttribute('src', base64)
                _this.getDomById('img-perv-div').innerHTML = ''
                _this.getDomById('img-perv-div').appendChild(img)
            } else {
                dialog
                    .showMessageBox({
                        type: 'warning',
                        title: '重要提示',
                        message: '请选择正确格式进行上传',
                    })
                    .then((res) => {
                        console.log(res)
                    })
            }
        },
        getDomById(id) {
            return document.getElementById(id)
        },
    },
}
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