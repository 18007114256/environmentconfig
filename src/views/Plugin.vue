<template>
    <div class="plugin-pages">
        <!-- <div class="back">
            <el-button type="info" size="mini" v-if="isShow" @click="isShow = false"
                >重新选择</el-button
            >
        </div> -->
        <!-- <h1>H5插件管理</h1>
        <div class="contentBox" v-if="!isShow">
            <div class="dropwrap" ref="dropwrap">
                请选择工程所在的根目录文件夹
                <div class="getDirUrl" @click="getDirUrl">+</div>
            </div>
        </div> -->
        <!-- <div class="tablebox">
            <div class="tableTitle">
                <p>ScpMock.ts文件</p>
                <p class="postion">所在位置：{{ url }}</p>
                <div class="tableTop">
                    <div>
                        <el-button type="primary" @click="addList">新增接口</el-button>
                        <el-button type="primary" class="save" @click="save">保存</el-button>
                    </div>
                    <el-switch
                        @change="allSet"
                        v-model="allType"
                        active-text="全部开启"
                        inactive-text="全部关闭"
                    >
                    </el-switch>
                </div>
            </div>
            <el-table :data="realMockList" border style="width: 100%">
                <el-table-column fixed="left" label="接口地址">
                    <template slot-scope="scope">
                        <el-input
                            v-model="scope.row.name"
                            placeholder="请输入内容"
                            type="text"
                        ></el-input>
                    </template>
                </el-table-column>
                <el-table-column fixed="right" label="操作" width="140">
                    <template slot-scope="scope">
                        <el-switch
                            v-model="scope.row.flag"
                            active-color="#409EFF"
                            inactive-color="#DCDFE6"
                        >
                        </el-switch>
                        <el-button
                            type="danger"
                            class="delete"
                            size="mini"
                            @click="delMock(scope.row)"
                            >删除</el-button
                        >
                    </template>
                </el-table-column>
            </el-table>
            <el-pagination
                @size-change="handleSizeChange"
                @current-change="handleCurrentChange"
                :current-page="currentPage"
                :page-sizes="[10]"
                :page-size="pagesize"
                layout="total, sizes, prev, pager, next, jumper"
                :total="this.mockList.filter((item) => !item.delete).length"
            >
            </el-pagination>
        </div> -->
        <el-dialog title="提示" :visible.sync="dialogVisible">
            <span>{{ tosatMsg }}</span>
            <span slot="footer" class="dialog-footer">
                <el-button type="primary" @click="dialogVisible = false">确 定</el-button>
            </span>
        </el-dialog>
    </div>
</template>
<script>
const { ipcRenderer: ipc } = window.require("electron");
const fs = window.require("fs"); //获取文件系统模块，负责读写文件
const dialog = window.require("electron").remote.dialog;
/**
 * 渲染进程
 */
export default {
    data() {
        return {
            isShow: false,
            mockList: ["空"],
            scpMockData: {
                start: "",
                end: "",
            },
            url: "",
            baseMock: {
                name: "",
                flag: false,
                delete: false,
            },
            allType: false,
            pagesize: 10,
            currentPage: 1,
            tosatMsg: "",
            dialogVisible: false,
        };
    },
    mounted() {
        ipc.on("sendPlugin", this.edCallBack);
    },
    computed: {
        realMockList() {
            let start = Number(this.currentPage - 1);
            return this.mockList
                .filter((item) => !item.delete)
                .slice(start * this.pagesize, this.currentPage * this.pagesize);
        },
    },
    methods: {
        // 初始页currentPage、初始每页数据数pagesize和数据data
        handleSizeChange: function (size) {
            this.pagesize = size;
        },
        handleCurrentChange: function (currentPage) {
            this.currentPage = currentPage;
        },
        allSet(flag) {
            this.mockList.forEach((item) => {
                item.flag = flag;
            });
        },
        delMock(item) {
            item.delete = true;
        },
        addList() {
            this.mockList.push(JSON.parse(JSON.stringify(this.mockList[0])));
        },
        save() {
            this.$message({
                message: "保存成功",
                type: "success",
                center: true,
            });
            let content = this.mockList
                .filter((item) => !item.delete)
                .map((item) => {
                    return `${item.flag ? "" : "//"}${item.name}`;
                })
                .reduce((pre, cur) => {
                    if (cur.indexOf("//") != -1) {
                        return pre + '\r//"' + cur.replace("//", "") + '"' + ",";
                    } else {
                        return pre + '\r"' + cur + '"' + ",";
                    }
                }, "");
            let resStr =
                this.scpMockData.start.join("\r") +
                content +
                "\r" +
                this.scpMockData.end.join("\r");
            fs.writeFileSync(this.url, resStr, "utf-8");
        },
        getDirUrl() {
            let _this = this;
            dialog
                .showOpenDialog({
                    properties: ["openFile", "openDirectory", "multiSelections"],
                    title: "请选择文件夹",
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
            url = url.split("\\").join("/");
            ipc.send("editDir", url);
        },
        edCallBack(event, data) {
            this.tosatMsg = data.msg;
            this.dialogVisible = true;
            if (!data.type) return;
            let scpMockUrl = data.data.scpMockUrl;
            this.url = scpMockUrl;
            this.readFile(scpMockUrl);
            this.isShow = data.type;
        },
        readFile(url) {
            let data = fs.readFileSync(url).toString().split("\r");
            let start = 0;
            let end = 0;
            let flag = true;
            let scpData = [];
            data.forEach((item, index) => {
                scpData.push(item);
                if (item.indexOf("ScpMockUrl") != -1 && flag) {
                    start = Number(index + 1);
                    flag = false;
                    this.scpMockData.start = scpData;
                    scpData = [];
                }
                if (item.indexOf("];") != -1 && data[Number(index + 1)] == "\n") {
                    end = index;
                    scpData = [];
                    scpData.push(item);
                }
            });
            this.scpMockData.end = scpData;
            this.mockList = data
                .slice(start, end)
                .filter((item) => item != "\n")
                .map((item) => {
                    let flag = true;
                    if (item.indexOf("//") != -1) {
                        flag = false;
                    }
                    return {
                        name: item.split('"')[1],
                        flag: flag,
                        delete: false,
                    };
                });
        },
    },
};
</script>

<style lang="less">
.plugin-pages {
    height: 100%;
    width: 100%;
    padding: 30px 50px;
    background: #fff;
    overflow-y: scroll;
    position: relative;
    .back {
        position: absolute;
        left: 50px;
        top: 28px;
    }
    .contentBox {
        display: flex;
        padding: 0 10px 20px;
        .dropwrap {
            height: 120px;
            width: 120px;
            border: 1px dashed #aaa;
            .getDirUrl {
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
    .tablebox {
        padding: 0 50px 50px;
        .tableTitle {
            text-align: left;
            .postion {
                user-select: text;
            }
            .tableTop {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding-bottom: 10px;
            }
        }
        .delete {
            margin-left: 20px;
        }
    }
}
</style>
