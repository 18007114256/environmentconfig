<template>
    <div class="rightBar">
        <div class="back" @click="back">返回</div>
        <div class="refresh" @click="refresh">刷新</div>
    </div>
</template>
<script>
export default {
    inject: ["reload"],
    data() {
        return {};
    },
    methods: {
        refresh() {
            // window.location.reload();
            this.reload();
        },
        back() {
            this.$router.goBack();
        },
    },
};
</script>
<style lang="less">
.rightBar {
    width: 100%;
    display: flex;
    justify-content: space-between;
    background-color: #fff;
    border-bottom: 1px solid #ccc;
    .back {
        padding-left: 30px;
        cursor: pointer;
    }
    .refresh {
        padding-right: 30px;
        cursor: pointer;
    }
}
</style>
