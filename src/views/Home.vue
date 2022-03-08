<template>
    <div class="home">
        <h1>审批页内容</h1>
        <code>
            <div>
                <h4>我是当前页内容</h4>
                <p>下载内容有我</p>
            </div>
        </code>
        <div class="select">
            <p>请选择保存类型</p>
            <div class="itemBox">
                <div
                    :class="['item', selectItem == item ? 'isSelect' : '']"
                    v-for="(item, index) in content"
                    :key="index"
                    @click="selected(item)"
                >
                    {{ item }}
                </div>
            </div>
        </div>
        本地
        <img style="border: 1px solid #f0f;" src="http://localhost:8889/app.png" alt="本地" class="imager" />
        <img style="border: 1px solid #0f0;" src="http://localhost:8888/app.png" alt="线上" class="imager" />
        线上
        <div class="butBox">
            <button @click="download(1)">下载当前页内容</button>
            <button @click="download(2)">下载指定页内容</button>
            <button @click="download(3)">下载指定文件夹内容</button>
        </div>
    </div>
</template>

<script>
// @ is an alias to /src
// const { ipcRenderer: ipc } = window.require('electron')
// const fs = window.require('fs')
// const dialog = window.require('electron').remote.dialog
// const path = window.require('path')
// const ProSinosun = path.join(__dirname, './sinosun-ui/index.html')
// const ProClient = path.join(__dirname, './SWP-Client')
// const DevSinosun = './public/sinosun-ui/index.html' //本地路径
// const DevClient = './public/SWP-Client' //本地路径
import DownLoadHandler from './DownLoadHandler.js'

export default {
    components: {},
    data() {
        return {
            content: ['.vue', '.html', '.js', '.json'],
            selectItem: '.vue',
        }
    },
    mounted() {},
    methods: {
        selected(item) {
            this.selectItem = item
        },
        download(type) {
            let data = {
                title: '保存文件',
                name: type == 3 ? 'SWP-H5-Client' : `index${this.selectItem}`,
                readPath: '',
                type: type,
            }
            DownLoadHandler.downLoadFunction(data).then((res) => {
                console.log('res', res)
                let obj = {}
                if (res) {
                    obj = {
                        type: 'info',
                        title: '提示信息',
                        message: '文件已下载完成，请进行后续操作。',
                    }
                } else {
                    obj = {
                        type: 'warning',
                        title: '重要提示',
                        message: '文件下载失败，请稍候重试。',
                    }
                }
                DownLoadHandler.showTip(obj).then((Res) => {
                    console.log('Res',Res)
                })
            })
        },
    },
}
</script>
<style lang="less">
.home {
    height: 100%;
    overflow-y: scroll;
    .select {
        width: 200px;
        margin: 0 auto;
        border: 1px solid #aaa;
        padding: 0 20px 20px;
        .itemBox {
            display: flex;
            justify-content: space-between;
            .item {
                display: flex;
                align-items: center;
                width: 40px;
                height: 30px;
                border: 1px dashed #ccc;
                text-align: right;
                cursor: pointer;
            }
            .isSelect {
                background: cornflowerblue;
                color: #fff;
            }
        }
    }
    .imager {
        margin-top: 20px;
    }
    .butBox {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 50px 0;
        width: 300px;
        margin: 0 auto;
        button {
            height: 60px;
            width: 80px;
        }
    }
}
</style>
