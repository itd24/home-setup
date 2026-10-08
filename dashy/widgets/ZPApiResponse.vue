<template>
  <div class="zpApiResponseContainer">
    <!-- Render the compiled HTML here -->
    <component :is="compiled"></component>
    <div v-if="loading" class="loading-spinner">
      <div class="spinner"></div>
    </div>
  </div>
</template>

<script>

import WidgetMixin from '@/mixins/WidgetMixin';
import Vue from 'vue/dist/vue.esm.js';
import Constants from '@/custom/Constants';

export default {
  mixins: [WidgetMixin],
  data() {
    return {
      loading: true,
      apiData: {},
      compiled: null,
    };
  },
  computed: {
    endpoint() {
      return this.options.endpoint;
    },
  },
  filters: {
    formatDate: function (value) {
      if (!value) return '';

      const date = new Date(value);

      const formatNumber = (num) => String(num).padStart(2, '0');

      const day = formatNumber(date.getDate());
      const month = formatNumber(date.getMonth() + 1); // Months are 0-based
      const year = date.getFullYear();
      const hours = formatNumber(date.getHours());
      const minutes = formatNumber(date.getMinutes());

      return `${day}.${month}.${year} ${hours}:${minutes}`;
    }
  },
  methods: {
    fetchData() {
      this.makeRequest(this.endpoint,Constants.authenticationHeaders).then(this.processData);
    },
    processData(data) {
      // Do processing any here, and set component data
      this.apiData = data;
      this.compileTemplate();
      this.loading = false;
    },
    compileTemplate() {
      // Compile the template dynamically with the API data
      const compiledTemplate = Vue.compile(this.options.template);
      this.compiled = Vue.component('dynamic-component', {
        render: compiledTemplate.render,
        staticRenderFns: compiledTemplate.staticRenderFns,
        data: () => ({ data: this.apiData }),
        filters: this.$options.filters
      });
    },
    checkProps() {
      const ops = this.options;
      if (!ops.endpoint) this.error('Missing endpoint');

      if (!ops.method || (ops.method !== 'GET' && ops.method !== 'POST')) {
        this.error('You have to define a request method, either GET or POST');
      }

      if(!ops.template) this.error('Missing template');
    },
  },
};
</script>

<style scoped lang="scss">
.zpApiResponseContainer {
  position: relative;
  color: white;
  a {
    color: white;
  }
}
</style>