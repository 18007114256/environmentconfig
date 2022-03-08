<template>
    <div class="tar">
        <h1>测试</h1>
        文件执行地址：<input type="text" name="" id="" v-model="url" /><br />
        cmd执行命令：<input type="text" name="" id="" v-model="cmd" /><br />
        执行命令成功内容：<textarea v-model="content" cols="30" rows="3"></textarea><br />
        执行命令失败内容：<textarea v-model="contentError" cols="30" rows="3"></textarea><br />
        退出之后 的内容：<textarea v-model="escContent" cols="30" rows="3"></textarea><br />
        <button @click="run">执行</button><br />
        <button @click="mock">执行scpmock</button><br />
        <button @click="close">终止scpmock</button><br />
    </div>
</template>

<script>
const exec = window.require("child_process").exec;
const path = window.require("path");
export default {
    data() {
        return {
            url: "",
            cmd: "",
            content: "",
            contentError: "",
            escContent: "",
            deleted: true,
        };
    },
    mounted() {},
    methods: {
        mock() {
            // const ProSinosun = path.join(__dirname, './sinosun-ui/index.html')
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
                });
                // 打印错误的后台可执行程序输出
                workerProcess.stderr.on("data", function (data) {
                    console.log("stderr: " + data);
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
        run() {
            let _this = this;
            // 任何你期望执行的cmd命令，ls都可以
            let cmdStr1 = this.cmd;
            let cmdPath = this.url;
            // 子进程名称
            let workerProcess;
            runExec(cmdStr1);
            function runExec(cmdStr) {
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
                });
                // 退出之后的输出
                workerProcess.on("close", function (code) {
                    console.log("out code：" + code);
                    _this.escContent += code + "\r";
                });
            }
        },
        close() {
            let _this = this;
            var cmd = "netstat -ano";
            var port = "80";
            exec(cmd, function (err, stdout) {
                if (err) {
                    return console.log(err);
                }

                stdout.split("\n").filter(function (line) {
                    var p = line.trim().split(/\s+/);
                    var address = p[1];

                    if (address != undefined) {
                        if (address.split(":")[1] == port && !_this.deleted) {
                            _this.deleted = true;
                            exec("taskkill /F /pid " + p[4], function (err) {
                                if (err) {
                                    return console.log("释放指定端口失败！！" + err);
                                }

                                _this.content += p[4] + "占用指定端口的程序被成功杀掉！"+'\n';
                                console.log("占用指定端口的程序被成功杀掉！");
                            });
                        }
                    }
                });
            });
        },
    },
};
</script>

<style lang="less"></style>
