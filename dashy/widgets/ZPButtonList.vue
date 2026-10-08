<template>
  <div class="zpButtonList">
    <div class="list">
      <div v-for="(item, index) in items" :key="index" class="button-container">
        <!-- Button -->
        <button @click="callApi(item, index)" v-if="!isAnyOtherDisplayed(item)">
          {{ item.title }}
        </button>

        <!-- Loading Indicator -->
        <div v-if="item.isLoading" class="loading-spinner">
          <div class="spinner"></div>
        </div>

        <!-- Success Message -->
        <div v-if="item.success" class="success">
          OK
        </div>

        <!-- Error Message -->
        <div v-if="item.error" class="error">
          Error loading. HTTP code: {{ item.httpCode }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import WidgetMixin from '@/mixins/WidgetMixin';
import Vue from 'vue/dist/vue.esm.js';
import Constants from '@/custom/Constants';
import FontAwesomeMixin from '@/custom/mixins/FontAwesomeMixin';

export default {
  mixins: [WidgetMixin, FontAwesomeMixin],
  data() {
    return {
      items: [],
    };
  },
  mounted() {
    if (this.options.items) {
      this.items = this.options.items.map(item => ({
        endpoint: item.endpoint,
        title: item.title,
        httpCode: null,
        success: false,
        error: false,
        isLoading: false
      }));
    }
  },
  computed: {},
  filters: {},
  methods: {
    isAnyOtherDisplayed(item){
      return item.isLoading || item.success || item.error;
    },
    setSuccessStatus(item){
      item.success = true;
      // Reset success message after 10 seconds
      setTimeout(() => {
        item.success = false;
      }, 2000);
    },
    setErrorStatus(item, statuscode){
      item.error = true;
        item.httpCode = statuscode;

        // Reset error message after 10 seconds
        setTimeout(() => {
          item.error = false;
          item.httpCode = null;
        }, 5000);
    },

    async callApi(item, index) {
      // Set loading state
      this.items[index].isLoading = true;
      this.items[index].success = false;
      this.items[index].error = false;

      try {
        const response = await fetch(item.endpoint, {
          method: 'GET',
          headers: Constants.authenticationHeaders,
        });
        this.items[index].isLoading = false;

        if (response.status == 200) {
          this.setSuccessStatus(this.items[index]);
        } else {
          this.setErrorStatus(this.items[index], response.status);
        }
      } catch (error) {
        this.items[index].isLoading = false;
        this.setErrorStatus(this.items[index], "Network Error");
      }
    }
  },
};
</script>

<style scoped lang="scss">
.zpButtonList {
  position: relative;
  color: white;
  padding: 10px 0 0 0;
  a {
    color: white;
  }
  .list {
    .button-container {
      padding: 10px 5px;
      button {
        width: 100%;
        height: 100%;
        min-height: 50px;
        background: transparent;
        border: 2px solid white;
        color: white;
        font-size: 20px;
        font-weight: bold;
      }
      .success,.error{
        height: 50px;
        line-height: 50px;
        font-size: 20px;
        text-align: center;
        font-weight: bold;
      }
      .success{
        color: green;
      }
      .error{
        color:red;
      }
    }
  }





  #loading {
  display: inline-block;
  width: 50px;
  height: 50px;
  border: 3px solid rgba(255,255,255,.3);
  border-radius: 50%;
  border-top-color: #fff;
  animation: spin 1s ease-in-out infinite;
  -webkit-animation: spin 1s ease-in-out infinite;
}
  .spinner {
    display: inline-block;
    width: 50px;
    height: 50px;
    border: 3px solid rgba(255,255,255,.3);
    border-radius: 50%;
    border-top-color: #fff;
    animation: spin 1s ease-in-out infinite;
    -webkit-animation: spin 1s ease-in-out infinite;
    position: relative;
    left: calc(50% - 25px);
  }
}

@keyframes spin {
  to { -webkit-transform: rotate(360deg); }
}
@-webkit-keyframes spin {
  to { -webkit-transform: rotate(360deg); }
}
</style>