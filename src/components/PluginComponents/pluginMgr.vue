<template>
    <div class="plugin-home">
        <!-- <div class="plugin-title">
            <div>客户端类型选择</div>
            <div>
                <el-select v-model="value" @change="selectChange" placeholder="请选择">
                    <el-option
                        v-for="item in options"
                        :key="item.value"
                        :label="item.label"
                        :value="item.value"
                    >
                    </el-option>
                </el-select>
            </div>
        </div> -->
        <el-divider></el-divider>
        <div class="listBox">
            <div v-if="!projectList.length"><el-empty description="暂无项目"></el-empty></div>
            <div class="listItem" v-for="(item, index) in projectList" :key="index">
                <div class="itemName" @click="jumpDetail(item)">{{ item.name }}</div>
                <i class="el-icon-close" @click="preDelete(item.id)"></i>
            </div>
        </div>
        <div class="bottomBox">
            <el-button type="primary" @click="dialogVisible = true">新建项目</el-button>
        </div>
        <el-dialog class="pluginMgrDialog" title="新建项目" :visible.sync="dialogVisible">
            <el-input v-model="projectName" placeholder="请输入项目名称" type="text"></el-input>
            <div class="ipBox">
                <el-input
                    class="ipInput"
                    v-model="projectIp"
                    placeholder="请输入ip地址"
                    type="text"
                ></el-input>
                <el-button type="primary" @click="syncIp">同步ip</el-button>
            </div>
            <div class="selectProject">
                <el-input
                    class="selectPath"
                    v-model="selectPath"
                    :disabled="true"
                    placeholder="请选择项目路径"
                    type="text"
                ></el-input>
                <el-button type="primary" @click="selectProject">选择</el-button>
            </div>
            <el-row>
                <el-radio size="medium" :border="true" v-model="radio1" label="bizmate"
                    >伴正事</el-radio
                >
                <el-radio size="medium" :border="true" v-model="radio1" label="yqt"
                    >银企通</el-radio
                >
            </el-row>
            <!-- <el-row>
                <el-radio size="medium" :border="true" v-model="radio2" label="mPaas"
                    >mPaas</el-radio
                >
                <el-radio size="medium" :border="true" v-model="radio2" label="Tchat"
                    >Tchat</el-radio
                >
            </el-row> -->
            <span slot="footer" class="dialog-footer">
                <el-button class="btn" type="danger" @click="dialogVisible = false"
                    >关 闭</el-button
                >
                <el-button class="btn" type="primary" @click="addProject">创 建</el-button>
            </span>
        </el-dialog>

        <el-dialog title="是否删除" :visible.sync="deleteFlag">
            <span slot="footer" class="dialog-footer">
                <el-button type="danger" @click="deleteFlag = false">取 消</el-button>
                <el-button type="primary" @click="deleteItem()">确 定</el-button>
            </span>
        </el-dialog>

        <el-dialog title="请输入" :visible.sync="passwordFlag">
            <span>检测到您的电脑没有安装xcodeproj,请输入开机密码为您自动安装</span>
            <el-input v-model="openPassword" placeholder="请输入开机密码" type="text"></el-input>
            <span slot="footer" class="dialog-footer">
                <el-button type="danger" @click="passwordFlag = false">取 消</el-button>
                <el-button type="primary" @click="passwordIn">确 定</el-button>
            </span>
        </el-dialog>
    </div>
</template>
<script>
import NativeBrige from "@/utils/NativeBrige.js";
import H5BrigeImpl from "@/utils/H5BrigeImpl.js";
import IosBrigeImpl from "@/utils/IosBrigeImpl.js";
import AndroidBrigeImpl from "@/utils/AndroidBrigeImpl.js";
import { setStorage, getStorage } from "../../utils/commonUtils.js";
import { mapState } from "vuex";
const { ipcRenderer: ipc } = window.require("electron");
const dialog = window.require("electron").remote.dialog;
/**
 * 渲染进程
 */
export default {
    data() {
        return {
            projectList: [],
            curId: 0,
            deleteId: "",
            dialogVisible: false,
            deleteFlag: false,
            selectPath: "",
            projectName: "",
            projectIp: "",
            radio1: "bizmate",
            radio2: "mPaas",
            platformMap: {
                bizmate: 101, // 伴正事
                yqt: 102, // 银企通
                mPaas: 201, // mpaas
                Tchat: 202, // 原生
            },
            loading: null,
            options: [
                // {
                //     value: "pluginH5",
                //     label: "H5",
                // },
            ],
            value: "pluginH5",
            passwordFlag: false,
            openPassword: "",
        };
    },
    beforeCreate() {
        ipc.send("getPlatform");
    },
    beforeMount() {
        this.initData();
        this.selectChange(this.pluginType);
        ipc.on("sendPlatform", this.getPlatform);
    },
    computed: {
        ...mapState({
            pluginType: "pluginType",
        }),
    },
    methods: {
        getPlatform(event, data) {
            let { platform } = data;
            console.log("platform", platform);
            if (platform == "darwin") {
                this.options.push({
                    value: "pluginIos",
                    label: "iOS",
                });
            }
            if (platform == "win32") {
                this.options.push({
                    value: "pluginAndroid",
                    label: "Android",
                });
            }
            this.options.length = 1;
            this.selectChange(this.options[0].value);
        },
        initData() {
            this.value = this.pluginType;
            this.curId = getStorage("curId") || 0;
            this.projectList =
                (getStorage(`projectList-${this.value}`) &&
                    JSON.parse(getStorage(`projectList-${this.value}`))) ||
                [];
        },
        syncIp() {
            let ip = getStorage("mockIpAndPort");
            if (ip) {
                this.tostMsg({
                    message: "同步成功",
                });
                this.projectIp = ip;
            } else {
                this.tostMsg({
                    message: "未获取到ip，请手动输入",
                    type: "error",
                });
            }
        },
        preDelete(id) {
            this.deleteId = id;
            this.deleteFlag = true;
        },
        jumpDetail(item) {
            this.$router.push({
                name: "projectDetail",
                query: {
                    info: item,
                },
            });
        },
        passwordIn() {
            if (this.openPassword === "") {
                this.tostMsg({
                    message: `密码不能为空`,
                    type: "error",
                });
                return;
            }
            this.passwordFlag = false;
            this.addProject();
        },
        addProject() {
            if (this.validateProject()) {
                this.curId++;
                setStorage("curId", this.curId);
                let project = {
                    id: this.curId,
                    name: this.projectName,
                    ip: this.projectIp,
                    basePath: this.selectPath,
                    product: this.platformMap[this.radio1],
                    framework: this.platformMap[this.radio2],
                    _vue: this,
                    password: this.openPassword,
                };
                this.loadingFn("项目创建中请稍等...");
                window.NativeBrige.creatProject(project)
                    .then((res) => {
                        delete project._vue;
                        this.projectList.push(project);
                        setStorage(`projectList-${this.value}`, JSON.stringify(this.projectList));
                        this.loading.close();
                        console.log("pluginMgr.vue - addProject - res", res);
                        this.tostMsg({
                            message: "创建成功",
                        });
                        this.dialogVisible = false;
                    })
                    .catch((err) => {
                        if (err.type == "password") {
                            this.getPassword();
                            return;
                        }
                        console.log("pluginMgr.vue - addProject - err", err);
                        this.loading.close();
                        this.tostMsg({
                            message: `创建失败：${err.msg}`,
                            type: "error",
                            duration: "10000",
                        });
                        this.dialogVisible = false;
                    });
            }
        },
        getPassword() {
            this.passwordFlag = true;
        },
        deleteItem() {
            let id = this.deleteId;
            this.projectList = this.projectList.filter((item) => item.id != id);
            window.NativeBrige.deleteLocalConfig(this.projectList);
            setStorage(`projectList-${this.value}`, JSON.stringify(this.projectList));
            this.deleteFlag = false;
        },
        selectProject() {
            dialog
                .showOpenDialog({
                    properties: ["openFile", "openDirectory", "multiSelections"],
                    title: "请选择文件夹",
                })
                .then((res) => {
                    if (!res.canceled) {
                        let basePath = res.filePaths[0];
                        this.selectPath = basePath;
                    }
                })
                .catch((req) => {
                    console.log(req);
                });
        },
        validateProject() {
            let re =
                /^((25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.){3}(25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))$/;
            let port = this.projectIp && this.projectIp.split(":")[1];
            console.log("port", port);
            if (this.projectList.some((item) => item.name == this.projectName)) {
                this.tostMsg({
                    message: "项目名称不能重复",
                    type: "error",
                });
                return false;
            } else if (this.projectName == "") {
                this.tostMsg({
                    message: "项目名称不能为空",
                    type: "error",
                });
                return false;
            } else if (this.projectIp == "") {
                this.tostMsg({
                    message: "ip地址不能为空",
                    type: "error",
                });
                return false;
            } else if (!re.test(this.projectIp) && !port) {
                this.tostMsg({
                    message: "请输入正确的ip地址",
                    type: "error",
                });
                return false;
            } else if (this.selectPath == "") {
                this.tostMsg({
                    message: "请选择项目路径",
                    type: "error",
                });
                return false;
            } else {
                return true;
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
        setNativeBrige(val) {
            let env = val;
            if (env == "pluginIos") {
                NativeBrige.setNativeBrigeImpl(IosBrigeImpl);
            } else if (env == "pluginAndroid") {
                NativeBrige.setNativeBrigeImpl(AndroidBrigeImpl);
            } else if (env == "pluginH5") {
                NativeBrige.setNativeBrigeImpl(H5BrigeImpl);
            }
            window.NativeBrige = NativeBrige;
        },
        selectChange(val) {
            console.log("val", val);
            this.$store.commit("changeType", val);
            this.setNativeBrige(val);
            this.initData();
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
