import Vue from 'vue'
import Cocoapp from './Cocoapp.vue'

Vue.config.productionTip = false

new Vue({
  render: h => h(Cocoapp),
}).$mount('#app')
