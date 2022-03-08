<template>
    <div class="project-detail-pages">
        <div class="mockTitle">
            <div class="title-left">{{ projectName }}</div>
            <div class="title-right">
                开启挡板功能
                <el-switch v-model="mockFlag" active-color="#409EFF" inactive-color="#DCDFE6">
                </el-switch>
            </div>
        </div>
        <div class="mockBody">
            <div class="mockBody-top">
                <el-input
                    class="projectIp"
                    :value="projectIp"
                    :disabled="true"
                    type="text"
                ></el-input>
                <!-- <el-tag class="info" type="info">与数据管理端同步</el-tag> -->
                <!-- <el-button type="primary" @click="dialogVisible = true">新增接口</el-button> -->

                <el-button type="success" @click="dialogVisible = true">导入接口</el-button>
                <!-- <el-button type="success" icon=" el-icon-upload" circle @click="importData"></el-button> -->
                <el-button type="primary" @click="showSyncAndGetConfig">同步接口信息</el-button>
            </div>
            <el-divider></el-divider>
            <div class="interfaceList">
                <div v-if="!interfaceList.length"><el-empty description="暂无接口"></el-empty></div>
                <div class="listItem" v-for="(item, index) in interfaceList" :key="index">
                    <!-- <div class="itemName" :title="item.name">{{ item.name }}</div> -->
                    <el-checkbox v-model="item.checked" :label="item.name"></el-checkbox>
                    <!-- <i class="el-icon-close" @click="preDelete(item.name)"></i> -->
                </div>
            </div>
        </div>

        <el-dialog class="pluginMgrDialog" title="导入接口" :visible.sync="dialogVisible">
            <el-tooltip class="tooltip" effect="dark" placement="top">
                <div slot="content">
                    <div class="content-top">
                        {{ `请选择xlsx类型文件` }}
                    </div>
                </div>
                <input id="file" type="file" />
            </el-tooltip>
            <span slot="footer" class="dialog-footer">
                <el-button class="btn" type="danger" @click="dialogVisible = false"
                    >关 闭</el-button
                >
                <el-button class="btn" type="primary" @click="importData(0)">新 增</el-button>
                <el-button class="btn" type="primary" @click="importData(1)">覆 盖</el-button>
            </span>
        </el-dialog>

        <el-dialog class="pluginMgrDialog" title="选择工程" :visible.sync="selectFlag">
            <div class="listItem" v-for="(item, index) in project" :key="index">
                <!-- <div class="itemName" :title="item.name">{{ item.name }}</div> -->
                <el-checkbox v-model="item.checked" :label="item.name"></el-checkbox>
                <!-- <i class="el-icon-close" @click="preDelete(item.name)"></i> -->
            </div>
            <span slot="footer" class="dialog-footer">
                <el-button class="btn" type="danger" @click="selectFlag = false">取 消</el-button>
                <el-button class="btn" type="primary" @click="syncData(0)">新 增</el-button>
                <el-button class="btn" type="primary" @click="syncData(1)">覆 盖</el-button>
            </span>
        </el-dialog>

        <div class="bottomBtn">
            <el-button @click="goBack">返回</el-button>
            <el-button type="primary" @click="saveMock">保存</el-button>
        </div>
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
            mockFlag: true,
            dialogVisible: false,
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
        this.projectName = info.name;
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
        // preDelete(name) {
        //     this.deleteName = name;
        //     this.selectFlag = true;
        // },
        // deleteItem() {
        //     let name = this.deleteName;
        //     this.interfaceList = this.interfaceList.filter((item) => item.name != name);
        //     this.projectInfoMap.interfaceList[this.currentId] = this.interfaceList;
        //     setStorage("projectMap", JSON.stringify(this.projectInfoMap.interfaceList));
        //     this.selectFlag = false;
        //     this.dataChange = true;
        // },
        // addInterface() {
        //     if (this.validateInterface()) {
        //         let interfaceObj = {
        //             name: this.interfaceName,
        //         };
        //         this.interfaceList.push(interfaceObj);
        //         this.projectInfoMap.interfaceList[this.currentId] = this.interfaceList;
        //         setStorage("projectMap", JSON.stringify(this.projectInfoMap.interfaceList));
        //         this.interfaceName = "";
        //         this.dialogVisible = false;
        //         this.dataChange = true;
        //     }
        // },
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
.project-detail-pages {
    padding: 20px;
    .mockTitle {
        display: flex;
        justify-content: space-between;
    }
    .mockBody {
        padding: 10px 0;
        .el-divider {
            margin: 10px 0;
        }
        &-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            .info {
                margin-right: 10px;
            }
            .projectIp {
                margin-right: 10px;
            }
        }
        .interfaceList {
            overflow: scroll;
            padding-right: 10px;
            height: calc(100vh - 240px);
            .listItem {
                display: flex;
                align-items: center;
                border: 1px solid #ccc;
                border-radius: 5px;
                padding: 10px;
                margin-bottom: 10px;
                position: relative;
                .itemName {
                    user-select: text;
                    width: 90%;
                    overflow: hidden;
                    white-space: nowrap;
                    text-overflow: ellipsis;
                    text-align: left;
                    font-size: 12px;
                }
                i {
                    position: absolute;
                    top: 50%;
                    right: 10px;
                    transform: translateY(-50%);
                    cursor: pointer;
                }
            }
        }
    }
    .bottomBtn {
        position: fixed;
        width: calc(100% - 241px);
        right: 0;
        bottom: 20px;
        .el-button {
            min-width: 150px;
        }
    }

    .listItem {
        display: flex;
        align-items: center;
        border: 1px solid #ccc;
        border-radius: 5px;
        padding: 10px;
        margin-bottom: 10px;
        position: relative;
        .itemName {
            user-select: text;
            width: 90%;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
            text-align: left;
            font-size: 12px;
        }
        i {
            position: absolute;
            top: 50%;
            right: 10px;
            transform: translateY(-50%);
            cursor: pointer;
        }
    }
}
</style>
