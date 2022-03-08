<template>
    <div class="about">
        <div>
            <span class="title">zip压缩</span>
            <div class="contentBox">
                <div class="dropwrap" ref="dropwrap">
                    支持拖拽区域
                    <div class="addImg">
                        zip压缩
                    </div>
                </div>
                <div class="dropwrap dropwrap2" ref="dropwrap2">
                    支持拖拽区域
                    <div class="addImg">
                        MD5加密
                    </div>
                </div>
                <div class="mask" v-if="maskShow">{{ tType }}无需md5加密</div>
                <div class="showBox">
                    <div>输入信息区域</div>
                    <div class="btm">
                        <div class="item">
                            版本号： <input type="text" v-model="version" /> <button @click="addFunc">+</button>
                        </div>
                        <div class="item">
                            小应用：
                            <select v-model="name">
                                <option v-for="(item, index) in appOption" :key="index" :value="formatValue(item)">{{
                                    item.name
                                }}</option>
                            </select>
                        </div>
                        <div class="item">
                            离线包版本：
                            <!-- <input type="radio" name="tItem" value="tChart" v-model="tType" />T信 -->
                            <input type="radio" name="tItem" value="mPaas" v-model="tType" />mPaas
                            <!-- <input type="radio" name="tItem" value="TMF" v-model="tType" />TMF -->
                        </div>
                        <div v-if="tType == 'TMF'">
                            <div class="item">
                                环境：
                                <input type="radio" name="eItem" value="SIT" v-model="eType" />SIT
                                <input type="radio" name="eItem" value="UAT" v-model="eType" />UAT
                                <input type="radio" name="eItem" value="OTHER" v-model="eType" />其他
                            </div>
                            <div class="item eItem" v-if="eType == 'OTHER'">
                                <div>例：yqtpoc1.sinosun.com-18443</div>
                            </div>
                            <div class="item" v-if="eType == 'OTHER'">
                                手动输入：
                                <input type="text" v-model="otherVal" />
                            </div>
                        </div>
                        <div class="item" v-if="tType == 'mPaas'">
                           离线资源包地址：
                           <input readonly type="text" name="" id="" :value="currentVal">
                        </div>
                        <div class="item" v-if="tType == 'mPaas'">
                           环境：
                            <input type="radio" name="eItem" value="SIT" v-model="authInfo.env" />SIT
                            <input type="radio" name="eItem" value="PROD" v-model="authInfo.env" />PROD
                        </div>
                        <div class="item" v-if="tType == 'mPaas'">
                            打包人：
                           <input type="text" name="" id="" v-model="authInfo.name">
                        </div>
                        <div class="item" v-if="tType == 'mPaas'">
                            备注：
                           <input type="text" name="" id="" v-model="authInfo.remark">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="loading" v-if="loading">
            急速压缩中，稍等片刻。
        </div>
    </div>
</template>

<script>
const fs = window.require('fs') //获取文件系统模块，负责读写文件
const crypto = window.require('crypto')
const JSZIP = require('jszip')
// const zip = new JSZIP()
// const fstream = window.require('fstream')
// const tar = window.require('tar');
// const tar = window.require('tar-fs')
// const compressing = window.require('compressing')
import DownLoadHandler from './DownLoadHandler.js'
import appOption from './ConstData'
// import axios from 'axios'
// import XLSX from 'xlsx'
export default {
    data() {
        return {
            version: '1.0.1',
            name: '00000022',
            appOption: appOption,   //所有小应用对应离线包信息
            zip: null,
            topPath: '',
            loading: false,
            tType: 'mPaas',
            eType: 'SIT',
            otherVal: '',
            filePath: '',
            sOption: {
                domain: 'yqtpoc2.sinosun.com',
                port: '19443',
            },
            eOption: {
                domain: 'yqtpoc1.sinosun.com',
                port: '18443',
            },
            //打包时信息
            authInfo:{
                name:'auth',
                time:this.formatDateTime(),
                env:'SIT',
                version:'',
                remark:'无'
            }
        }
    },
    computed: {
        maskShow() {
            if (this.tType == 'tChart') {
                return false
            } else {
                return true
            }
        },
        currentVal(){
            let num = 0 ;
            let _this = this;
            this.appOption.forEach((item,index)=>{
                if(item.mValue == _this.name){
                    num = index
                }
            })
            return this.appOption[num]['tValue']
        }
    },
    mounted() {
        this.dropFun()
        this.drop2Fun()
        // this.getTar()
        // this.main()
    },
    methods: {
        // getExcel() {
        //     let _this = this
        //     let url =
        //         'https://yqtpoc2.sinosun.com:19443/file/download?params=eyJmaWxlSWQiOiJSalJmWTJWbE9HSmxPREpoTlRReE5ETXpOR0V5T1dOak5UTTBOV1ExTjJReU5EUmZORFExTXpnNE1UQTROVGsxTWciLCJ0b2tlbiI6ImV5SmhjSEJKWkNJNklqRTJOemMzTWpVMklpd2liWE4wY0Vsa0lqb2lORFExTkRFME9UVXlNVFF4TUNJc0ltVjRjSFJwYldVaU9pSXhOakk0TVRJME16UTVJaXdpWTNKbFlYUnBiMjVVYVcxbElqb3hOVGsyTlRnNE16UTVMQ0p6YVdkdVlYUjFjbVVpT2lKTlIxRkZTVXBJUVdkMVQxZERObmRVZVhSblUxQjJSSEZETW5OTlkyWkZZV0pNTkROblNtbGhOMmw0YWpoNlZVbENSVUoxYkVadFRtdHBORzlQU1hVM2RISnlUMFZSYmxwVWVWQnNlVXR0YTBkRWF5MU5VVkpSVkZWdFlUTmlWMlUyTTNKUlkwcFBRMjFyZEhWek5HZFRNRWhvVHpWUFNERTBZMUJYVUZaNGFXUldZMnhNUmsxSkluMD0ifQ=='
        //     axios.get(url, { responseType: 'arraybuffer' }).then((res) => {
        //         console.log(res)
        //         let arr = _this.readExcel(res.data)
        //         console.log(arr)
        //     })
        // },
        // //读取excel文件  格式 ‘arraybuf’
        // // ExcelImport.js 文件内已封装
        // readExcel(arraybuf, type = 'json') {
        //     var wb
        //     var arr
        //     var data = new Uint8Array(arraybuf)
        //     wb = XLSX.read(data, {
        //         type: 'array',
        //     })
        //     arr = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]])
        //     if ('csv' === type) {
        //         arr = XLSX.utils.sheet_to_csv(wb.Sheets[wb.SheetNames[0]])
        //     }
        //     return arr
        // },
        formatValue(item) {
            if (this.tType == 'tChart') {
                return item.tValue
            } else if (this.tType == 'mPaas') {
                return item.mValue
            } else if (this.tType == 'TMF') {
                return item.tmfValue
            }
        },
        addFunc() {
            let num = this.version.lastIndexOf('.')
            let arr = this.version.split('.')
            this.version = this.version.slice(0, num) + `.${Number(arr[arr.length - 1]) + 1}`
        },
        // zip压缩
        dropFun() {
            let _this = this
            let dropwrapper = this.$refs.dropwrap
            dropwrapper.addEventListener('drop', (e) => {
                e.preventDefault()
                const files = e.dataTransfer.files
                if(_this.eType=='OTHER'&&_this.otherVal == ''){
                    alert('文件名不能为空，请重新输入。')
                    return
                }   
                if (files) {
                    _this.startZIP(files[0].path)
                }
            })
            dropwrapper.addEventListener('dragover', (e) => {
                e.preventDefault()
            })
        },
        // md5加密
        drop2Fun() {
            let _this = this
            let dropwrapper = this.$refs.dropwrap2
            dropwrapper.addEventListener('drop', (e) => {
                e.preventDefault()
                const files = e.dataTransfer.files
                if (files) {
                    _this.md5File(files[0].path)
                }
            })
            dropwrapper.addEventListener('dragover', (e) => {
                e.preventDefault()
            })
        },
        //读取目录及文件
        readDir(obj, nowPath) {
            let _this = this
            let files = fs.readdirSync(nowPath) //读取目录中的所有文件及文件夹（同步操作）
            files.forEach((fileName, index) => {
                //遍历检测目录中的文件
                console.log(fileName, index) //打印当前读取的文件名
                let fillPath = nowPath + '/' + fileName
                let file = fs.statSync(fillPath) //获取一个文件的属性
                if (file.isDirectory()) {
                    //如果是目录的话，继续查询
                    let dirlist = '';
                    if(fileName == 'static'){
                        dirlist = _this.zip.folder(_this.filePath + '/' + fillPath.split(_this.topPath)[1]).file("ver_sion.json", JSON.stringify(this.authInfo)) //压缩对象中生成该目录
                    }else{
                        dirlist = _this.zip.folder(_this.filePath + '/' + fillPath.split(_this.topPath)[1]) //压缩对象中生成该目录
                    }
                    this.readDir(dirlist, fillPath) //重新检索目录文件
                } else {
                    obj.file(fileName, fs.readFileSync(fillPath)) //压缩目录添加文件
                }
            })
        },
        //开始压缩文件
        startZIP(path) {
            let _this = this
            this.filePath = this.name
            this.loading = true
            this.topPath = path + '/'
            this.zip = new JSZIP()
            if (typeof this.name == 'object') {
                this.filePath = this.eType == 'OTHER' ? this.otherVal : this.name.domain + '-' + this.name.port
                this.filePath += '/static/' + this.name.value
            }
            this.readDir(this.zip.folder(this.filePath), path)
            this.zip
                .generateAsync({
                    //设置压缩格式，开始打包
                    type: 'nodebuffer', //nodejs用
                    compression: 'DEFLATE', //压缩算法
                    compressionOptions: {
                        //压缩级别
                        level: 9,
                    },
                })
                .then(function (content) {
                    _this.loading = false
                    let names = _this.name
                    if (typeof _this.name == 'object') {
                        names = _this.name.domain + '-' + _this.name.port
                    }
                    let data = {
                        title: '保存离线资源包',
                        name: `${_this.eType == 'OTHER'?_this.otherVal:names}.zip`,
                        readPath: '',
                        type: 4,
                    }
                    DownLoadHandler.downLoadFunction(data).then((res) => {
                        console.log('res', res)
                        fs.writeFileSync(res.filePath, content, 'utf-8') //将打包的内容写入 当前目录下的 result.zip中
                    })
                })
        },
        md5File(path) {
            let data = fs.readFileSync(path)
            let num = path.lastIndexOf('\\')
            let newPath = path.slice(0, num)
            var md5Value = crypto.createHash('md5').update(data, 'utf8').digest('hex')
            fs.rename(path, newPath + '\\' + `H5-${this.name}-${this.version}-${md5Value}.zip`, (error) => {
                if (error) {
                    console.log(error)
                } else {
                    console.log('ok')
                }
            })
        },
        //时间格式化
        formatDateTime() {  
            let date = new Date
            var y = date.getFullYear();  
            var m = date.getMonth() + 1;  
            m = m < 10 ? ('0' + m) : m;  
            var d = date.getDate();  
            d = d < 10 ? ('0' + d) : d;  
            var h = date.getHours();  
            h=h < 10 ? ('0' + h) : h;  
            var minute = date.getMinutes();  
            minute = minute < 10 ? ('0' + minute) : minute;  
            var second=date.getSeconds();  
            second=second < 10 ? ('0' + second) : second;  
            return y + '-' + m + '-' + d+' '+h+':'+minute+':'+second;  
        }
        // getTar() {
        //     tar.pack('C:/D/project/Electron/SWP-tools-client/public/test').pipe(
        //         fs.createWriteStream('C:/D/project/Electron/SWP-tools-client/public/my-tarball.tar')
        //     )
        // },
        // async main() {
        //     try {
        //         await compressing.tar.compressDir('./public/test', './public/test.tar')
        //         await compressing.gzip.compressFile('./public/test.tar', './public/test.tar')
        //         console.log('success')
        //     } catch (err) {
        //         console.error(err)
        //     }
        // },
    },
    watch: {
        name(newVal) {
            console.log('name', newVal)
        },
        tType(newVal) {
            console.log(newVal)
            let _this = this
            let arr = ['mValue', 'tValue', 'tmfValue']
            this.appOption.forEach((item) => {
                for (let key in item) {
                    if (item[key] == _this.name) {
                        _this.$nextTick(() => {
                            switch (arr.indexOf(key)) {
                                case 0:
                                    _this.name = newVal == 'TMF' ? item[arr[2]] : item[arr[1]]
                                    break
                                case 1:
                                    _this.name = newVal == 'mPaas' ? item[arr[0]] : item[arr[2]]
                                    break
                                case 2:
                                    _this.name = newVal == 'tChart' ? item[arr[1]] : item[arr[0]]
                                    break
                            }
                        })
                    }
                }
            })
        },
        eType: {
            handler(newVal) {
                let _this = this
                if (newVal == 'SIT') {
                    this.appOption.forEach((item) => {
                        item.tmfValue.domain = _this.sOption.domain
                        item.tmfValue.port = _this.sOption.port
                    })
                    this.otherVal = ''
                } else if (newVal == 'UAT') {
                    this.appOption.forEach((item) => {
                        item.tmfValue.domain = _this.eOption.domain
                        item.tmfValue.port = _this.eOption.port
                    })
                    this.otherVal = ''
                }
                console.log('this.appOption', this.appOption)
                console.log('this.name', this.name)
            },
            immediate: true,
        },
        version:{
            handler(val){
                this.authInfo.version = val
            },
            immediate:true
        }
    },
}
</script>

<style lang="less">
.about {
    height: 100%;
    position: relative;
    .title {
        font-size: 30px;
        display: inline-block;
        padding-bottom: 20px;
    }
    .contentBox {
        position: relative;
        display: flex;
        padding: 0 10px 20px;
        .dropwrap {
            height: 120px;
            width: 120px;
            border: 1px dashed #aaa;
            .addImg {
                line-height: 100px;
            }
        }
        .dropwrap2 {
            position: absolute;
            top: 180px;
        }
        .mask {
            height: 80px;
            width: 120px;
            position: absolute;
            border: 1px solid #ccc;
            padding-top: 40px;
            top: 180px;
            background-color: rgba(220, 220, 220, 0.9);
        }
        .showBox {
            position: relative;
            width: calc(100% - 150px);
            height: 100%;
            margin-left: 20px;
            border: 1px dashed #aaa;
            min-height: 300px;
            .btm {
                position: absolute;
                left: 0;
                .item {
                    display: flex;
                    justify-content: flex-start;
                    margin-top: 10px;
                    button {
                        margin-left: 10px;
                    }
                }
                .eItem {
                    font-size: 16px;
                    color: rgb(71, 124, 221);
                }
            }
        }
    }
    .loading {
        position: absolute;
        width: 100%;
        height: 100%;
        left: 0;
        right: 0;
        top: 0;
        bottom: 0;
        background-color: rgba(188, 188, 188, 0.9);
        color: #000;
        font-size: 20px;
        line-height: 300px;
    }
}
</style>