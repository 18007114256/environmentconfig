<template>
    <div class="plugin-home-pages">
        <h1>scpMock配置及启动</h1>
        <div class="tablebox">
            <div class="listItem">
                <span>ip地址</span
                ><el-input v-model="ip" placeholder="请输入内容" type="text"></el-input>
            </div>
            <div class="listItem">
                <span>端口号</span
                ><el-input v-model="port" placeholder="请输入内容" type="text"></el-input>
            </div>
            <div class="tabletitle">
                <div>
                    <el-button type="primary" @click="addList">新增项目</el-button>
                    <!-- <el-button type="primary" class="save" @click="setConfig">保存</el-button> -->
                </div>
                <div>
                    <el-button type="success" @click="run">运行服务</el-button>
                    <el-button type="danger" @click="close">终止服务</el-button>
                </div>
            </div>

            <el-table :data="realProject" border style="width: 100%">
                <el-table-column fixed="left" label="项目名称">
                    <template slot-scope="scope">
                        <el-input
                            v-model="scope.row.name"
                            placeholder="请输入内容"
                            type="text"
                        ></el-input>
                    </template>
                </el-table-column>
                <el-table-column fixed="right" label="操作" width="80">
                    <template slot-scope="scope">
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
                :total="this.project.filter((item) => !item.delete).length"
            >
            </el-pagination>

            <el-dialog title="提示" :visible.sync="dialogVisible">
                <span>{{ tosatMsg }}</span>
                <span slot="footer" class="dialog-footer">
                    <el-button type="primary" @click="dialogVisible = false">取 消</el-button>
                    <el-button type="primary" @click="editIp">确 定</el-button>
                </span>
            </el-dialog>
        </div>
    </div>
</template>
<script>
const { ipcRenderer: ipc } = window.require("electron");
const exec = window.require("child_process").exec;
const path = window.require("path");
import { editConfig, getConfig } from "../../utils/editConfig.js";
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
            curIp: "",
            tosatMsg: "",
            initModule: false,
            loading: null,
        };
    },
    created() {
        this.initData();
    },
    mounted() {
        ipc.on("sendCurIp", this.setCurIp);
    },
    computed: {
        realProject() {
            let start = Number(this.currentPage - 1);
            return this.project
                .filter((item) => !item.delete)
                .slice(start * this.pagesize, this.currentPage * this.pagesize);
        },
    },
    methods: {
        loadingFn() {
            this.loading = this.$loading({
                lock: true,
                text: "依赖安装中请稍候。",
                spinner: "el-icon-loading",
                background: "rgba(0, 0, 0, 0.7)",
            });
        },
        editIp() {
            this.dialogVisible = false;
            if (!this.initModule) {
                this.ip = this.curIp;
                this.setConfig();
            } else {
                this.loadingFn()
                this.initScpmock();
            }
        },
        initScpmock() {
            let _this = this;
            let scpPath = path.resolve("./resources/app/scpmock");
            let cmdstr = "cnpm i";
            // 子进程名称
            let workerProcess;
            runExec(cmdstr, scpPath);
            function runExec(cmdStr, cmdPath) {
                workerProcess = exec(cmdStr, { cwd: cmdPath });
                // 打印正常的后台可执行程序输出
                workerProcess.stdout.on("data", function (data) {
                    console.log("stdout: " + data);
                    _this.content += data;
                });
                // 打印错误的后台可执行程序输出
                workerProcess.stderr.on("data", function (data) {
                    console.log("stderr: " + data);
                    _this.contentError += data;
                    if (data.indexOf(`All packages installed`) != -1) {
                        _this.loading.close();
                        _this.tostMsg({
                            message: "依赖安装完成",
                        });
                        return;
                    }
                });
                // 退出之后的输出
                workerProcess.on("close", function (code) {
                    console.log("out code：" + code);
                    _this.escContent += code + "\r";
                });
            }
        },
        setCurIp(event, data) {
            let ip = data.ip;
            let re =
                /(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)/;
            if (re.test(ip) && this.ip !== ip) {
                this.tosatMsg = `获取到您当前的ip为 ${ip} ，是否进行赋值并保存。`;
                this.curIp = ip;
                this.dialogVisible = true;
                this.initModule = false;
            }
        },
        close() {
            let _this = this;
            var cmd = "netstat -ano";
            var port = this.port;
            exec(cmd, function (err, stdout) {
                if (err) {
                    _this.tostMsg({
                        message: "cmd执行失败" + err,
                        type: "error",
                    });
                    return console.log(err);
                }
                let flag = true;
                stdout.split("\n").filter(function (line) {
                    var p = line.trim().split(/\s+/);
                    var address = p[1];

                    if (address != undefined) {
                        if (address.split(":")[1] == port && !_this.deleted) {
                            flag = false;
                            _this.deleted = true;
                            exec("taskkill /F /pid " + p[4], function (err) {
                                if (err) {
                                    _this.tostMsg({
                                        message: "释放指定端口失败！！" + err,
                                        type: "error",
                                    });
                                    return console.log("释放指定端口失败！！" + err);
                                }
                                _this.tostMsg({
                                    message: `${_this.port}端口的服务已结束`,
                                    type: "success",
                                });
                                console.log(`${_this.port}端口的程序已结束`);
                            });
                        }
                    }
                });
                if (flag) {
                    _this.tostMsg({
                        message: `${_this.port}端口未在运行中`,
                        type: "error",
                    });
                }
            });
        },
        run() {
            // this.setConfig();
            let _this = this;
            let num = __dirname.indexOf("node_modules");
            let devSrc = __dirname.slice(0, num - 1);
            let DevSinosun = path.join(devSrc, "./public/scpmock");
            let cmdPath =
                process.env.NODE_ENV === "development"
                    ? DevSinosun
                    : path.join(__dirname, "./scpmock");
            let cmdstr = "node scpmock.js";
            // 子进程名称
            let workerProcess;
            runExec(cmdstr, cmdPath);
            function runExec(cmdStr, cmdPath) {
                workerProcess = exec(cmdStr, { cwd: cmdPath });
                // 打印正常的后台可执行程序输出
                workerProcess.stdout.on("data", function (data) {
                    console.log("stdout: " + data);
                    _this.content += data;
                    _this.deleted = false;
                    if (data.indexOf(`Server started at ${_this.port}`) != -1) {
                        _this.tostMsg({
                            message: "运行成功",
                        });
                        _this.openChrome();
                        return;
                    } else if (data.indexOf(`address already in use`) != -1) {
                        _this.tostMsg({
                            message: `运行失败:${_this.port}端口已占用`,
                            type: "error",
                        });
                        return;
                    }
                });
                // 打印错误的后台可执行程序输出
                workerProcess.stderr.on("data", function (data) {
                    console.log("stderr: " + data);
                    if (data.indexOf(`Cannot find module`) != -1) {
                        _this.tosatMsg = "scpmock缺少module依赖 是否进行安装";
                        _this.dialogVisible = true;
                        _this.initModule = true;
                        return;
                    }
                    _this.contentError += data;
                    _this.deleted = false;
                });
                // 退出之后的输出
                workerProcess.on("close", function (code) {
                    console.log("out code：" + code);
                    _this.escContent += code + "\r";
                    _this.deleted = false;
                });
            }
        },
        openChrome() {
            let url = "http://" + this.ip + ":" + this.port + "/~scpmock";
            ipc.send("openChrome", { url });
        },
        // 初始页currentPage、初始每页数据数pagesize和数据data
        handleSizeChange: function (size) {
            this.pagesize = size;
        },
        handleCurrentChange: function (currentPage) {
            this.currentPage = currentPage;
        },
        addList() {
            this.project.push(JSON.parse(JSON.stringify(this.project[0])));
        },
        delMock(item) {
            item.delete = true;
        },
        initData() {
            let config = getConfig();
            Object.keys(config).forEach((item) => {
                this[item] = config[item];
            });
            this.project = this.project.map((item) => {
                return {
                    name: item,
                    delete: false,
                };
            });
            ipc.send("getCurIp", { ip: this.ip });
        },
        setConfig() {
            let options = {
                port: this.port,
                project: this.project.filter((item) => !item.delete).map((item) => item.name),
                ip: this.ip,
            };
            let msg = editConfig(options);
            this.tostMsg({
                message: msg,
                type: "success",
            });
        },
        tostMsg({ message = "保存成功", type = "success" }) {
            this.$message({
                message: message,
                type: type,
                center: true,
                showClose: true,
            });
        },
    },
};
</script>
<style lang="less">
.plugin-home-pages {
    overflow-y: scroll;
    height: 100%;
    .tablebox {
        padding: 0 50px 50px;
        .tabletitle {
            width: 100%;
            display: flex;
            justify-content: space-between;
            padding-bottom: 10px;
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
</style>
