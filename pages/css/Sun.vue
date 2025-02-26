<script lang="ts" setup>
</script>

<template>
  <div class="w-full min-h-100vh flex flex-wrap justify-center items-center bg-black">
    <Sun class="w-300px h-400px overflow-hidden" />
    <Sun class="w-300px h-400px overflow-hidden" base-color="#0984e3" light-color="#6c5ce7" :light-num="4" />
    <Sun class="w-300px h-400px overflow-hidden" base-color="#00cec9" light-color="#fdcb6e" :light-num="8" />
    <Sun class="w-300px h-400px overflow-hidden" base-color="#1dd1a1" light-color="#ff9ff3" :light-num="12" />
  </div>
</template>
