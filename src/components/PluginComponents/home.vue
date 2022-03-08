<template>
    <div class="plugin-home-pages">
        <h1>插件管理</h1>
        <div class="btnBox">
            <el-button
                type="primary"
                v-for="(item, index) in pluginList"
                :key="index"
                @click="jump(item)"
                >{{ item.name }}</el-button
            >
        </div>
    </div>
</template>
<script>
export default {
    data() {
        return {
            pluginList: [
                {
                    name: "scpMock服务",
                    path: "pluginScpMock",
                },
                {
                    name: "H5插件管理",
                    path: "plugin",
                },
                {
                    name: "Android插件管理",
                    path: "pluginAndroid",
                },
                {
                    name: "Ios插件管理",
                    path: "pluginIos",
                },
            ],
        };
    },
    methods: {
        jump(item) {
            this.$router.push(`/${item.path}`);
        },
    },
};
</script>
<style lang="less">
.plugin-home-pages {
    .btnBox {
        padding: 20px 80px 0;
        display: flex;
        flex-wrap: wrap;
        justify-content: space-between;
        .el-button {
            width: 40%;
            margin-left: 0;
            margin-bottom: 20px;
            text-align: center;
        }
    }
}
</style>
