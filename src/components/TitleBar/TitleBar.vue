<template>
    <div id="mytitle">
        <div class="left">
            <img :src="require('@/assets/logo.png')" alt="" />
            <p>{{ titleName }}</p>
        </div>
        <div class="right">
            <TitleBtn type="min"></TitleBtn>
            <TitleBtn type="max"></TitleBtn>
            <TitleBtn type="close"></TitleBtn>
        </div>
    </div>
</template>

<script>
import "./TitleBar.less";
import TitleBtn from "../TitleBtn/TitleBtn.vue";
export default {
    name: "titleBar",
    components: {
        TitleBtn,
    },
    props: [],
    data() {
        return {
            titleName: "",
        };
    },
    created() {
        this.titleName ="SCP_MOCK 客户端"
            // process.env.CURRENT_PRO == "pluginScpmock"
            //     ? "SCP_MOCK 数据管理端"
            //     : "SCP_MOCK 客户端插件";

    },
    methods: {},
};
</script>
<style lang="less">
#mytitle {
    position: relative;
    width: 100%;
    height: 52px;
    background-color: rgb(71, 138, 238);
    -webkit-app-region: drag;
    .left {
        height: 100%;
        display: flex;
        img {
            height: 76%;
            border-radius: 50%;
            margin: auto 10px;
        }
        p {
            color: #fff;
        }
    }
}
</style>
