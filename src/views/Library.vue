<template>
    <div class="library">
        <h1>文档</h1>
        <el-table :data="docList" border height="450" style="width: 518px; margin: 0 auto;">
            <el-table-column prop="num" label="序号" width="50"> </el-table-column>
            <el-table-column prop="name" label="文件名" width="350"> </el-table-column>
            <el-table-column fixed="right" label="操作" width="100">
                <template slot-scope="scope">
                    <el-button @click="handleClick(scope.row)" type="text" size="small">查看</el-button>
                    <el-button @click="downLoad(scope.row)" type="text" size="small">下载</el-button>
                </template>
            </el-table-column>
        </el-table>
    </div>
</template>

<script>
const fs = window.require('fs')
import DownLoadHandler from './DownLoadHandler.js'
export default {
    data() {
        return {
            docList: [],
            nowPath: './public/sinosun-ui',
        }
    },
    mounted() {
        this.getFiles()
    },
    methods: {
        getFiles() {
            let _this = this
            let files = fs.readdirSync(this.nowPath)
            console.log('files', files)
            files.forEach((fileName, index) => {
                //遍历检测目录中的文件
                console.log(fileName, index) //打印当前读取的文件名
                let obj = {
                    name: fileName,
                    path: this.nowPath + '/' + fileName,
                    fType: fileName.isFile() ? '1' : '2',
                }
                _this.docList.push(obj)
                // let fillPath = nowPath + '/' + fileName
                // let file = fs.statSync(fillPath) //获取一个文件的属性
                // if (file.isDirectory()) {
                //     //如果是目录的话，继续查询
                //     let dirlist = _this.zip.folder(_this.name + '/' + fillPath.split(_this.topPath)[1]) //压缩对象中生成该目录
                //     this.readDir(dirlist, fillPath) //重新检索目录文件
                // } else {
                //     obj.file(fileName, fs.readFileSync(fillPath)) //压缩目录添加文件
                // }
            })
            _this.docList.forEach((item, index) => {
                item['num'] = index + 1
            })
            console.log('docList', _this.docList)
        },
        handleClick(val) {
            console.log('val', val)
            let data = {
                title: '下载文件',
                name: val.name,
                type: 2,
                loadPath: val.path,
            }
            DownLoadHandler.downLoadFunction(data).then((res) => {
                console.log('res', res)
            })
        },
        downLoad(val) {
            console.log('val', val)
        },
    },
}
</script>

<style lang="less">
.library {
    height: 100%;
    overflow-y: scroll;
}
</style>