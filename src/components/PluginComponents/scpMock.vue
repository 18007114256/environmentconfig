<template>
    <div class="plugin-home-pages">
        <div class="mock-title">
            <input id="copyInput" style="opacity: 0; position: absolute; z-index: -10" />
        </div>
        <div class="tablebox">
            <div class="tabletitle">
                <div>
                    <el-button type="success" v-show="!localChromeShow" @click="run"
                        >运行服务</el-button
                    >
                    <el-button type="danger" @click="close">终止服务</el-button>
                </div>
                <div>
                    <el-tooltip
                        class="tooltip"
                        effect="dark"
                        placement="top"
                        v-if="localChromeShow"
                    >
                        <div slot="content">
                            <div class="content-top">
                                {{ `客户端配置地址 ${ip}:${port} `
                                }}<i class="el-icon-document-copy" @click="copyIp(0)"></i>
                            </div>
                            <div>
                                {{ `mock服务地址 ${ip}:${port}/~scpmock `
                                }}<i class="el-icon-document-copy" @click="copyIp(1)"></i>
                            </div>
                        </div>
                        <el-tag class="info" type="info">服务信息</el-tag>
                    </el-tooltip>
                    <el-button type="primary" v-show="!localChromeShow" @click="addList"
                        >添加项目</el-button
                    >
                </div>
            </div>

            <div class="contentBox" v-show="!localChromeShow">
                <el-table :data="realProject" border style="width: 100%">
                    <el-table-column fixed="left" label="项目名称">
                        <template slot-scope="scope">
                            <p>{{ scope.row.name }}</p>
                        </template>
                    </el-table-column>
                    <el-table-column fixed="right" class="operation" label="操作" width="80">
                        <template slot-scope="scope">
                            <el-button
                                type="danger"
                                class="delete"
                                size="mini"
                                @click="
                                    () => {
                                        activeDelete = scope.row.id;
                                        deleteFlag = true;
                                    }
                                "
                                >删除</el-button
                            >
                        </template>
                    </el-table-column>
                </el-table>

                <el-pagination
                    v-show="paginationShow"
                    @size-change="handleSizeChange"
                    @current-change="handleCurrentChange"
                    :current-page="currentPage"
                    :page-sizes="[10]"
                    :page-size="pagesize"
                    layout="total, sizes, prev, pager, next, jumper"
                    :total="this.project.filter((item) => !item.delete).length"
                >
                </el-pagination>

                <el-dialog title="提示" :visible.sync="dialogVisible">
                    <span>{{ tosatMsg }}</span>
                    <el-input
                        v-if="this.platform == 'darwin'"
                        v-model="openPassword"
                        placeholder="请输入开机密码"
                        type="text"
                    ></el-input>
                    <span slot="footer" class="dialog-footer">
                        <el-button type="danger" @click="dialogVisible = false">取 消</el-button>
                        <el-button type="primary" @click="initScpmock">确 定</el-button>
                    </span>
                </el-dialog>

                <el-dialog title="提示" :visible.sync="nodeDialog">
                    <span>{{ nodeTosatMsg }}</span>
                    <span slot="footer" class="dialog-footer">
                        <el-button type="danger" @click="nodeDialog = false">取 消</el-button>
                        <el-button type="primary" @click="nodeDialog = false">确 定</el-button>
                    </span>
                </el-dialog>

                <el-dialog title="添加项目" :visible.sync="addProFlag">
                    <el-input
                        v-model="addedProName"
                        placeholder="请输入项目名称"
                        type="text"
                    ></el-input>
                    <span slot="footer" class="dialog-footer">
                        <el-button type="danger" @click="addProFlag = false">取 消</el-button>
                        <el-button type="primary" @click="addList(true)">确 定</el-button>
                    </span>
                </el-dialog>

                <el-dialog title="是否确认删除" :visible.sync="deleteFlag">
                    <span slot="footer" class="dialog-footer">
                        <el-button type="danger" @click="deleteFlag = false">取 消</el-button>
                        <el-button type="primary" @click="delMock()">确 定</el-button>
                    </span>
                </el-dialog>
            </div>
        </div>

        <webview
            v-show="localChromeShow"
            id="geekori"
            :src="localChromeUrl"
            style="width: 100%; height: 75vh; border: 1px solid #ccc"
        ></webview>
    </div>
</template>
<script>
const { ipcRenderer: ipc } = window.require("electron");
const exec = window.require("child_process").exec;
// const iconv = window.require("iconv-lite");
const path = window.require("path");
import { editConfig, getConfig } from "../../utils/editConfig.js";
import { setStorage, getStorage, deleteStorage } from "../../utils/commonUtils.js";
import { mapState } from "vuex";
// scpmock 数据管理端
// scpmock 客户端插件
export default {
    data() {
        return {
            port: "",
            project: [1],
            ip: "",
            pagesize: 10,
            currentPage: 1,
            content: "",
            dialogVisible: false,
            tosatMsg: "",
            loading: null,
            running: false,
            addProFlag: false,
            deleteFlag: false,
            nodeDialog: false,
            addedProName: "",
            activeDelete: "",
            index: 0,
            prePort: "",
            runExecId: 0,
            runExecMap: {},
            nodeTosatMsg: "",
            localChromeShow: false,
            localChromeUrl: "",
            runCmd: "",
            cnpmCmd: "",
            closeCmd: "",
            platform: "",
            openPassword: "",
        };
    },
    computed: {
        ...mapState({
            isRun: "running",
            localUrl: "localChromeUrl",
        }),
        realProject() {
            let start = Number(this.currentPage - 1);
            return this.project
                .filter((item) => !item.delete)
                .slice(start * this.pagesize, this.currentPage * this.pagesize);
        },
        paginationShow() {
            return this.project.filter((item) => !item.delete).length > 10;
        },
    },
    created() {
        this.initData();
        this.prePort = getStorage("mockPort");
        ipc.send("getPlatform");
        ipc.on("sendPlatform", this.getPlatform);
    },
    beforeMount() {
        if (this.localUrl !== "") {
            this.localChromeShow = this.isRun;
        }
        if (this.localChromeShow) {
            this.localChromeUrl = this.localUrl;
        }
    },
    mounted() {
        ipc.on("sendCurIp", this.setCurIp);
        ipc.on("transData", this.transDataFn);
    },
    methods: {
        getPlatform(event, data) {
            let { platform } = data;
            this.platform = platform;
            if (platform == "darwin") {
                this.runCmd = "/usr/local/bin/node scpmock.js";
                this.cnpmCmd = "sh run.sh";
                this.closeCmd = `lsof -i:${this.port}`;
            }
            if (platform == "win32") {
                this.runCmd = "node scpmock.js";
                this.cnpmCmd = "cnpm i";
                this.closeCmd = `netstat -ano`;
            }
        },
        transDataFn(event, datas) {
            let { id, data } = datas;
            this.runExecMap[id] && this.runExecMap[id](data);
        },
        loadingFn(msg) {
            this.loading = this.$loading({
                lock: true,
                text: msg,
                spinner: "el-icon-loading",
                background: "rgba(0, 0, 0, 0.7)",
            });
        },
        initScpmock() {
            let mockMsg = "依赖安装中请稍候";
            this.loadingFn(mockMsg);
            this.dialogVisible = false;
            let _this = this;
            // let scpPath = path.resolve("./resources/app/scpmock");
            let num = __dirname.indexOf("node_modules");
            let devSrc = __dirname.slice(0, num - 1);
            let DevSinosun = path.join(devSrc, "./public/scpmock");
            let cmdPath =
                process.env.NODE_ENV === "development"
                    ? DevSinosun
                    : path.join(__dirname, "./scpmock");

            let cmdstr =
                this.platform == "win32"
                    ? this.cnpmCmd
                    : this.cnpmCmd + " " + cmdPath + " " + this.openPassword; //cnpm i
            // 子进程名称
            this.runExec(
                cmdstr,
                cmdPath,
                (data) => {
                    console.log("scpMock.vue -- initScpmock -- data studout :", data);
                    if (data.indexOf(`Sorry, try again`) != -1) {
                        _this.loading && _this.loading.close();
                        _this.tosatMsg = "开机密码输入错误，请重新输入";
                        _this.dialogVisible = true;
                        _this.openPassword = "";
                        return;
                    }
                },
                (data) => {
                    console.log("scpMock.vue -- initScpmock -- data :", data);
                    if (data.indexOf(`All packages installed`) != -1) {
                        _this.loading && _this.loading.close();
                        _this.tostMsg({
                            message: "依赖安装完成",
                        });
                        return;
                    }
                    if (
                        data.indexOf(`不是内部或外部命令`) != -1 ||
                        (data.indexOf(`command not found`) != -1 && data.indexOf(`cnpm`) != -1)
                    ) {
                        _this.loading && _this.loading.close();
                        _this.nodeTosatMsg = "本机暂无cnpm,请参考使用手册进行安装";
                        _this.nodeDialog = true;
                        return;
                    }
                },
            );
        },
        copyIp(type) {
            let input = document.getElementById("copyInput");
            let msg = "";
            if (type) {
                input.value = `${this.ip}:${this.port}/~scpmock`;
                msg = "mock服务地址复制成功";
            } else {
                input.value = `${this.ip}:${this.port}`;
                msg = "客户端配置地址复制成功";
            }
            input.select(); // 选中文本
            document.execCommand("Copy");
            this.tostMsg({
                message: msg,
            });
        },
        setCurIp(event, data) {
            let ip = data.ip;
            let re =
                /(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)/;
            if (re.test(ip) && this.ip !== ip) {
                this.ip = ip;
                this.tostMsg({
                    message: "本机ip获取成功",
                });
                this.loading && this.loading.close();
            }
        },
        close() {
            let _this = this;
            var cmd = this.closeCmd; //"netstat -ano";
            var port = this.port;
            _this.running = false;
            this.localChromeShow = false;
            this.$store.commit("changeRun", false);
            exec(cmd, function (err, stdout) {
                if (err) {
                    _this.tostMsg({
                        message: "cmd执行失败" + err,
                        type: "error",
                    });
                    return console.log(err);
                }
                let flag = true;
                let num = 0;
                stdout.split("\n").filter(function (line, index) {
                    if (!index) return;
                    var p = line.trim().split(/\s+/);
                    var address = p[1];
                    var serName = p[0];

                    if (address != undefined) {
                        if (_this.platform == "win32") {
                            if (address.split(":")[1] == port && !_this.deleted) {
                                flag = false;
                                _this.deleted = true;
                                if (p[3] != "LISTENING") return (flag = true);
                                exec("taskkill /F /pid " + p[4], function (err) {
                                    if (err) {
                                        _this.tostMsg({
                                            message: "释放指定端口失败！！" + err,
                                            type: "error",
                                        });
                                        return console.log("释放指定端口失败！！" + err);
                                    }
                                    _this.tostMsg({
                                        message: `服务已结束`,
                                        type: "success",
                                    });
                                    deleteStorage("mockPort");
                                    deleteStorage("mockIpAndPort");
                                });
                            }
                        } else if (serName == "SCP_MOCK_") {
                            return;
                        } else if (serName == "node") {
                            flag = false;
                            _this.deleted = true;
                            exec("kill -9 " + address, function (err) {
                                if (num) return;
                                num++;
                                setTimeout(() => {
                                    num = 0;
                                }, 500);
                                if (err) {
                                    _this.tostMsg({
                                        message: "释放指定端口失败！！" + err,
                                        type: "error",
                                    });
                                    return console.log("释放指定端口失败！！" + err);
                                }
                                _this.tostMsg({
                                    message: `服务已结束`,
                                    type: "success",
                                });
                                // setTimeout(() => {

                                // }, 1000);
                                // _this.$nextTick(() => {
                                //     console.log("bbbbbbbbb");
                                // });
                                deleteStorage("mockPort");
                                deleteStorage("mockIpAndPort");
                            });
                        }
                    }
                });
                if (flag) {
                    _this.tostMsg({
                        message: `服务未在运行中`,
                        type: "error",
                    });
                }
            });
        },
        run() {
            this.setConfig();
            let _this = this;
            let num = __dirname.indexOf("node_modules");
            let devSrc = __dirname.slice(0, num - 1);
            let DevSinosun = path.join(devSrc, "./public/scpmock");
            let cmdPath =
                process.env.NODE_ENV === "development"
                    ? DevSinosun
                    : path.join(__dirname, "./scpmock");
            let cmdstr = this.runCmd; // "node scpmock.js";
            let nums = 0;
            // 子进程名称
            this.runExec(
                cmdstr,
                cmdPath,
                (data) => {
                    console.log("scpMock.vue -- run -- data :", data);
                    _this.deleted = false;
                    if (data.indexOf(`Server started at ${_this.port}`) != -1 && !nums) {
                        nums++;
                        setTimeout(() => {
                            nums = 0;
                        }, 1000);

                        _this.$nextTick(() => {
                            this.tostMsg({
                                message: "运行成功",
                            });
                        });
                        // this.tostMsg({
                        //     duration: "5000",
                        //     dangerouslyUseHTMLString: true,
                        //     message:
                        //         "<p class='run-success'>运行成功 <strong><i>url地址已复制</i></strong></p><p>打开浏览器访问mock首页</p>",
                        // });
                        // let input = document.getElementById("copyInput");
                        // input.value = `${this.ip}:${this.port}/~scpmock`;
                        // input.select(); // 选中文本
                        // document.execCommand("Copy");
                        setStorage("mockPort", _this.port);
                        setStorage("mockIpAndPort", `${this.ip}:${this.port}`);
                        _this.prePort = _this.port;
                        _this.running = true;
                        _this.openChrome();
                        return;
                    } else if (data.indexOf(`address already in use`) != -1) {
                        if (_this.prePort == _this.port) {
                            _this.tostMsg({
                                message: `当前端口被占用，正在尝试自动终止`,
                                type: "error",
                            });
                            // _this.running = false;
                            setTimeout(() => {
                                _this.close();
                            }, 500);
                            return;
                        } else {
                            _this.port = Number(Number(_this.port) + 1);
                            if (_this.port == 87) {
                                _this.port++;
                            }
                            _this.run();
                            return;
                        }
                    }
                },
                (data) => {
                    if (data.indexOf(`Cannot find module`) != -1) {
                        _this.tosatMsg = `scpmock缺少module依赖 是否进行安装\n${
                            _this.platform == "darwin" ? "安装依赖需要输入开机密码" : ""
                        }`;
                        _this.dialogVisible = true;
                        return;
                    }
                    if (
                        data.indexOf(`不是内部或外部命令`) != -1 ||
                        data.indexOf(`command not found`) != -1
                    ) {
                        _this.nodeTosatMsg = "本机暂无node环境,请参考使用手册进行安装";
                        _this.nodeDialog = true;
                        return;
                    }
                    _this.deleted = false;
                },
                () => {
                    _this.deleted = false;
                },
            );
        },
        openChrome() {
            let url = "http://" + this.ip + ":" + this.port + "/~scpmock";
            // ipc.send("openChrome", { url });
            this.localChromeUrl = url;
            this.$store.commit("setLocalUrl", url);
            this.localChromeShow = true;
            this.$store.commit("changeRun", true);
        },
        // 初始页currentPage、初始每页数据数pagesize和数据data
        handleSizeChange: function (size) {
            this.pagesize = size;
        },
        handleCurrentChange: function (currentPage) {
            this.currentPage = currentPage;
        },
        validataProName() {
            if (!this.addedProName) {
                this.tostMsg({
                    message: "项目名称不能为空",
                    type: "error",
                });
                return false;
            }
            if (this.project.some((item) => item.name == this.addedProName)) {
                this.tostMsg({
                    message: "项目名称不能重复",
                    type: "error",
                });
                return false;
            }
            return true;
        },
        addList(flag) {
            if (flag == true && this.validataProName()) {
                this.index++;
                this.project.push({
                    id: this.index,
                    name: this.addedProName,
                    delete: false,
                });
                this.addedProName = "";
                this.addProFlag = false;
                this.tostMsg({
                    message: "添加成功",
                });
            } else {
                this.addProFlag = true;
            }
        },
        delMock() {
            this.project.forEach((item) => {
                if (item.id == this.activeDelete) {
                    item.delete = true;
                }
            });
            this.deleteFlag = false;
            this.tostMsg({
                message: "删除成功",
            });
        },
        initData() {
            ipc.send("getCurIp", { ip: this.ip });
            let config = getConfig();
            Object.keys(config).forEach((item) => {
                this[item] = config[item];
            });
            this.project = this.project.map((item) => {
                this.index++;
                return {
                    id: this.index,
                    name: item,
                    delete: false,
                };
            });
            if (this.ip == 0) {
                let mockMsg = "获取本机ip中请稍候";
                this.loadingFn(mockMsg);
            }
        },
        setConfig() {
            let options = {
                port: this.port,
                project: this.project.filter((item) => !item.delete).map((item) => item.name),
                ip: this.ip,
            };
            editConfig(options);
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
                offset: 40,
            });
        },
        runExec(cmdStr, cmdPath, stdoutCB, stderrCB, closeCB = () => {}) {
            let _this = this;
            var binaryEncoding = "GBK";
            let workerProcess = exec(cmdStr, { cwd: cmdPath, encoding: binaryEncoding });
            // 打印正常的后台可执行程序输出
            workerProcess.stdout.on("data", function (data) {
                _this.runExecId++;
                _this.runExecMap[_this.runExecId] = stdoutCB;
                console.log("runExec ==> stdout: " + data);
                ipc.send("doTransData", {
                    data: data,
                    id: _this.runExecId,
                });
            });
            // 打印错误的后台可执行程序输出
            workerProcess.stderr.on("data", function (data) {
                _this.runExecId++;
                _this.runExecMap[_this.runExecId] = stderrCB;
                console.log("runExec ==> stderr: " + data);
                ipc.send("doTransData", {
                    data: data,
                    id: _this.runExecId,
                });
            });
            // 退出之后的输出
            workerProcess.on("close", function (code) {
                console.log("out code：" + code);
                closeCB(code);
            });
        },
    },
};
</script>
<style lang="less">
.plugin-home-pages {
    overflow-y: scroll;
    height: 100%;
    padding: 40px 50px;
    .mock-title {
        width: 100%;
        display: flex;
        justify-content: space-between;
        align-items: center;
        .tooltip {
            margin-left: 10px;
        }
    }
    .tablebox {
        // padding-bottom: 50px;
        .tabletitle {
            width: 100%;
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            .tooltip {
                margin-right: 10px;
            }
        }
        .listItem {
            width: 100%;
            display: flex;
            justify-content: flex-start;
            align-items: center;
            padding: 10px 0;
            span {
                color: #909399;
                font-weight: bold;
                line-height: 23px;
                min-width: 70px;
                text-align: left;
            }
        }
    }
}
.run-success {
    margin-bottom: 5px !important;
}
.content-top {
    margin-bottom: 5px;
}
</style>
