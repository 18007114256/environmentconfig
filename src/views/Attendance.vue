<template>
    <div class="about">
        <h1>考勤页内容</h1>
        <div class="contentBox">
            <div class="dropwrap" ref="dropwrap">
                支持拖拽区域
                <div class="fileName">
                    {{ fileName }}
                </div>
            </div>
            <div class="showBox">
                <div>展示区域</div>
                <codemirror ref="myCm" :value="resArr" :options="cmOptions" class="code"></codemirror>
            </div>
        </div>
    </div>
</template>
<script>
// const { ipcRenderer: ipc } = window.require('electron')
/**
 * 渲染进程
 */
import { codemirror } from 'vue-codemirror'
import DownLoadHandler from './DownLoadHandler.js'
const dialog = window.require('electron').remote.dialog
const fs = window.require('fs')
require('codemirror/mode/python/python.js')
require('codemirror/addon/fold/foldcode.js')
require('codemirror/addon/fold/foldgutter.js')
require('codemirror/addon/fold/brace-fold.js')
require('codemirror/addon/fold/xml-fold.js')
require('codemirror/addon/fold/indent-fold.js')
require('codemirror/addon/fold/markdown-fold.js')
require('codemirror/addon/fold/comment-fold.js')
export default {
    components: {
        codemirror,
    },
    data() {
        return {
            resArr: '',
            fileName: '无',
            cmOptions: {
                value: '',
                //mode:'text/html',//模式
                theme: 'darcula', //主题
                indentUnit: 2,
                smartIndent: true,
                tabSize: 4,
                readOnly: true, //只读
                showCursorWhenSelecting: true,
                lineNumbers: false, //是否显示行数
                firstLineNumber: 1,
            },
        }
    },
    mounted() {
        this.dropFun()
    },
    methods: {
        dropFun() {
            let _this = this
            const dropwrapper = this.$refs.dropwrap
            dropwrapper.addEventListener('drop', (e) => {
                e.preventDefault()
                const files = e.dataTransfer.files
                if (files) {
                    console.log('path', files[0].path)
                    let extensions = DownLoadHandler.fileExtensionCheck(files[0].path)
                    if (extensions == 'CODE' || extensions == 'TXT') {
                        const content = fs.readFileSync(files[0].path, 'utf-8')
                        console.log('content', content.toString())
                        _this.resArr = content.toString()
                        _this.fileName = files[0].name
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
                }
            })
            dropwrapper.addEventListener('dragover', (e) => {
                e.preventDefault()
            })
        },
    },
}
</script>

<style lang='less'>
.about {
    width: 100%;
    height: 100%;
    .contentBox {
        display: flex;
        padding: 0 10px 20px;
        .dropwrap {
            height: 120px;
            width: 120px;
            border: 1px dashed #aaa;
            .fileName {
                word-break: break-all;
                padding-top: 36px;
            }
        }
        .showBox {
            width: calc(100% - 150px);
            height: 100%;
            margin-left: 20px;
            border: 1px dashed #aaa;
            .code {
                width: 100%;
                text-align: left;
                .CodeMirror {
                    height: calc(100vh - 200px);
                }
            }
        }
    }
}
</style>