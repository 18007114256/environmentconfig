<template>
    <div class="plugin-home">
        <el-divider></el-divider>
        <div class="listBox">
            <div v-if="!environmentList.length"><el-empty description="暂无环境"></el-empty></div>
            <div class="listItem" v-for="(item, index) in environmenttList" :key="index">
                <div class="itemName" @click="dialogVisible1 = true">{{ item.name }}</div>
                <!-- <i class="el-icon-close" @click="preDelete(item.id)"></i> -->
            </div>
        </div>
        <div class="bottomBox">
            <el-button @click="goBack">  返回  </el-button>
            <el-button type="primary" @click="dialogVisible = true">新建环境</el-button>
        </div>

        <el-dialog class="pluginMgrDialog" title="新建环境" :visible.sync="dialogVisible">
            <el-input v-model="environmentName" placeholder="请输入环境名称" type="text"></el-input>
            <div class="selectProject">
                <el-input
                    class="selectPath"
                    v-model="selectPath"
                    :disabled="true"
                    placeholder="请选择环境路径"
                    type="text"
                ></el-input>
                <el-button type="primary" @click="selectProject">选择</el-button>
            </div>

            <span slot="footer" class="dialog-footer">
                <el-button class="btn" type="danger" @click="dialogVisible = false"
                    >关 闭</el-button
                >
                <el-button class="btn" type="primary" @click="addEnvironment">创 建</el-button>
            </span>
        </el-dialog>

        <el-dialog class="pluginMgrDialog" title="配置环境" :visible.sync="dialogVisible1">
            <el-input v-model="environmentName" :disabled="true" type="text"></el-input>
            <div class="selectProject">
                <el-input
                    class="selectPath"
                    v-model="selectPath1"
                    :disabled="true"
                    placeholder="请选择环境路径"
                    type="text"
                ></el-input>
                <el-button type="primary" @click="selectProject">选择</el-button>
            </div>

            <span slot="footer" class="dialog-footer">
                <el-button class="btn" type="danger" @click="dialogVisible1 = false"
                    >关 闭</el-button
                >
                <el-button class="btn" type="primary" @click="modifyEnvironment">创 建</el-button>
            </span>
        </el-dialog>
    </div>
</template>
<script>
import { setStorage } from "../../utils/commonUtils.js";
import { getConfig } from "../../utils/editConfig.js";
import { mapState } from "vuex";
import XLSX from "xlsx";
// const _ = window.require("lodash");
export default {
    computed: {
        ...mapState({
            pluginType: "pluginType",
        }),
    },
    data() {
        return {
            environmentList: [],
            environmentName: "",
            selectPath: "",
            selectPath1: "",
            mockFlag: true,
            dialogVisible: false,
            dialogVisible1: false,
            selectFlag: false,
            projectName: "",
            projectIp: "",
            projectPath: "",
            product: "",
            framework: "",
            interfaceList: [],
            interfaceName: "",
            deleteName: "",
            projectInfoMap: {},
            currentId: 0,
            loading: null,
            dataChange: false,
            project: {},
        };
    },
    created() {
        let { info } = this.$route.query;
        this.currentId = info.id;
        // this.projectName = info.name;
        this.projectIp = info.ip;
        this.projectPath = info.basePath;
        this.product = info.product;
        this.framework = info.framework;
        this.projectInfoMap = window.NativeBrige.getProjectInfo();
        this.interfaceList = this.projectInfoMap.interfaceList[this.currentId] || [];
    },
    beforeMount() {
        this.initData();
    },
    methods: {
        addEnvironment() {
            // if (this.validateProject()) {
            //     this.curId++;
            //     setStorage("curId", this.curId);
            //     let project = {
            //         id: this.curId,
            //         name: this.projectName,
            //         ip: this.projectIp,
            //         basePath: this.selectPath,
            //         product: this.platformMap[this.radio1],
            //         framework: this.platformMap[this.radio2],
            //         _vue: this,
            //         password: this.openPassword,
            //     };
            //     this.loadingFn("项目创建中请稍等...");
            //     window.NativeBrige.creatProject(project)
            //         .then((res) => {
            //             delete project._vue;
            //             this.projectList.push(project);
            //             setStorage(`projectList-${this.value}`, JSON.stringify(this.projectList));
            //             this.loading.close();
            //             console.log("pluginMgr.vue - addProject - res", res);
            //             this.tostMsg({
            //                 message: "创建成功",
            //             });
            //             this.dialogVisible = false;
            //         })
            //         .catch((err) => {
            //             if (err.type == "password") {
            //                 this.getPassword();
            //                 return;
            //             }
            //             console.log("pluginMgr.vue - addProject - err", err);
            //             this.loading.close();
            //             this.tostMsg({
            //                 message: `创建失败：${err.msg}`,
            //                 type: "error",
            //                 duration: "10000",
            //             });
            //             this.dialogVisible = false;
            //         });
            // }
            this.dialogVisible = false;
        },
        modifyEnvironment() {

            this.dialogVisible1 = false;
        },
        importData(type) {
            let _this = this;
            let fileObj = document.getElementById("file").files[0];
            if (fileObj) {
                var fileReader = new FileReader();
                fileReader.onload = function (ev) {
                    try {
                        var data = ev.target.result,
                            workbook = XLSX.read(data, {
                                type: "binary",
                            }); // 以二进制流方式读取得到整份excel表格对象
                    } catch (e) {
                        _this.tostMsg({
                            message: "文件类型不正确",
                            type: "error",
                        });
                        return;
                    }
                    let improtData = workbook.SheetNames.map((item) => {
                        return {
                            name: item,
                            checked: true,
                        };
                    });
                    // _this.interfaceList = _.unionWith(_this.interfaceList, improtData, _.isEqual);

                    if (type == 0) {
                        let keys = _this.interfaceList.map((item) => item.name);
                        improtData.forEach((item) => {
                            if (!keys.includes(item.name)) {
                                _this.interfaceList.push(item);
                            }
                        });
                    } else if (type == 1) {
                        _this.interfaceList = improtData.map((item) => {
                            return {
                                name: item.name,
                                // checked: _this.interfaceList
                                //     .filter((items) => items.name == item.name)
                                //     .map((itemm) => itemm.checked)[0],
                                checked: true,
                            };
                        });
                    }

                    _this.dialogVisible = false;
                    _this.tostMsg({
                        message: "导入成功",
                    });
                };

                // 以二进制方式打开文件
                fileReader.readAsBinaryString(fileObj);
            } else {
                _this.tostMsg({
                    message: "请选择文件",
                    type: "error",
                });
            }
        },
        showSyncAndGetConfig() {
            let { project } = getConfig();
            if (!project.length) {
                this.tostMsg({
                    message: "本机未检测到数据管理端，暂无法同步接口信息",
                    type: "error",
                });
                return;
            }
            this.project = project.map((item, index) => {
                return {
                    name: item,
                    index: `p${index + 1}`,
                    checked: true,
                };
            });
            console.log("project", project);
            this.selectFlag = true;
        },
        syncData(type) {
            let _this = this;
            let query;
            let multi = this.project
                .filter((item) => item.checked)
                .map((item) => item && item.index);
            console.log(multi);
            if (multi.length == 0) {
                this.tostMsg({
                    message: "请选择工程",
                    type: "error",
                });
                return;
            } else {
                query = {
                    multi: multi.length == 1 ? false : true,
                    project:
                        multi.length == 1
                            ? this.project
                                  .filter((item) => item.checked)
                                  .map((item) => item.index)[0]
                            : this.project.filter((item) => item.checked).map((item) => item.index),
                };
            }

            window.NativeBrige.getSyncDataInfo(query).then((data) => {
                if (type == 0) {
                    data.forEach((item) => {
                        if (!_this.interfaceList.map((item) => item.name).includes(item.name)) {
                            _this.interfaceList.push(item);
                        }
                    });
                } else if (type == 1) {
                    _this.interfaceList = data.map((item) => {
                        return {
                            name: item.name,
                            checked: _this.interfaceList
                                .filter((items) => items.name == item.name)
                                .map((itemm) => itemm.checked)[0],
                        };
                    });
                }

                this.tostMsg({
                    message: "同步成功",
                });
                this.selectFlag = false;
            });
        },

        validateInterface() {
            if (this.interfaceList.some((item) => item.name == this.interfaceName)) {
                this.tostMsg({
                    message: "接口名称不能重复",
                    type: "error",
                });
                return false;
            } else if (this.interfaceName == "") {
                this.tostMsg({
                    message: "接口名称不能为空",
                    type: "error",
                });
                return false;
            } else {
                return true;
            }
        },
        goBack() {
            this.$router.goBack();
        },
        initData() {
            console.log(
                this.projectName,
                this.projectIp,
                this.projectPath,
                this.product,
                this.framework,
            );
        },
        saveMock() {
            if (this.dataChange) {
                this.loadingFn("接口信息保存中请稍等...");
                this.projectInfoMap.interfaceList[this.currentId] = this.interfaceList.filter(
                    (item) => item.checked,
                );
                setStorage(
                    `projectMap-${this.pluginType}`,
                    JSON.stringify(this.projectInfoMap.interfaceList),
                );
                let info = {
                    mockFlag: this.mockFlag,
                    interfaceList: this.interfaceList.filter((item) => item.checked),
                    id: this.currentId,
                };
                window.NativeBrige.setProjectInfo(info)
                    .then((data) => {
                        console.log(data);
                        this.loading.close();
                        this.tostMsg({});
                        this.dataChange = false;
                    })
                    .catch((err) => {
                        this.loading.close();
                        this.tostMsg({
                            message: err.msg,
                            type: "error",
                            duration: "10000",
                        });
                        this.dataChange = true;
                    });
            } else {
                this.tostMsg({});
            }
        },
        tostMsg({
            message = "保存成功",
            type = "success",
            dangerouslyUseHTMLString = "false",
            duration = "3000",
        }) {
            this.$message({
                message: message,
                type: type,
                center: true,
                dangerouslyUseHTMLString: dangerouslyUseHTMLString,
                duration: duration,
                showClose: true,
            });
        },

        loadingFn(msg) {
            this.loading = this.$loading({
                lock: true,
                text: msg,
                spinner: "el-icon-loading",
                background: "rgba(0, 0, 0, 0.7)",
            });
        },
    },
    watch: {
        mockFlag(val) {
            console.log(val);
            this.dataChange = true;
        },
        interfaceList: {
            handler(val) {
                console.log(val);
                this.dataChange = true;
            },
            deep: true,
        },
    },
};
</script>
<style lang="less">
.plugin-home {
    box-sizing: border-box;
    width: 100%;
    padding: 10px 50px 30px;
    overflow: scroll;
    height: calc(100vh - 110px);
    .plugin-title {
        display: flex;
        justify-content: space-between;
        align-items: center;
        .el-select {
            width: 100px;
        }
    }
    .el-divider--horizontal {
        margin: 10px 0;
    }
    .listBox {
        padding: 0 20px 80px 20px;
        .listItem {
            display: flex;
            align-items: center;
            border: 1px solid #ccc;
            border-radius: 5px;
            padding: 10px;
            margin-bottom: 20px;
            .itemName {
                width: 100%;
                text-align: center;
                cursor: pointer;
            }
            i {
                cursor: pointer;
            }
        }
    }
    .bottomBox {
        width: calc(100%);
        position: fixed;
        background: #fff;
        bottom: 0;
        right: 0;
        padding: 10px 0;
        border-top: 1px solid #ccc;
        z-index: 10;
    }
}
.pluginMgrDialog {
    .el-dialog {
        width: 90% !important;
        .el-dialog__body {
            & > div {
                margin-bottom: 10px;
            }
            .el-row {
                display: flex;
                justify-content: flex-start;
            }
            .el-radio {
                min-width: 100px;
                display: flex;
                justify-content: flex-start;
            }
        }
        .dialog-footer {
            width: 100%;
            display: flex;
            justify-content: space-between;
            .btn {
                width: 45%;
                max-width: 200px;
            }
        }
        .ipBox {
            display: flex;
            justify-content: space-between;
            .ipInput {
                margin-right: 18px;
            }
        }
        .selectProject {
            display: flex;
            justify-content: space-between;
            align-items: center;
            .selectPath {
                // padding: 10px 10px 10px 16px;
                // border-radius: 4px;
                // border: 1px solid #dcdfe6;
                width: 100%;
                margin: 0 10px 0 0;
                text-align: left;
                min-height: 18px;
            }
        }
    }
}
</style>
