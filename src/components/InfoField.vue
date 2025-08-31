<template>
  <div class="info-field d-flex align-center">
    <v-icon :size="20" color="grey-darken-1" class="mr-3">
      {{ icon }}
    </v-icon>
    <div class="flex-grow-1">
      <div class="text-caption text-grey-darken-1">{{ label }}</div>
      <div class="text-body-1 font-weight-medium">{{ value || 'Non renseigné' }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  label: string
  value?: string
  icon: string
}

defineProps<Props>()
</script>

<style scoped>
.info-field {
  padding: 8px 0;
  border-radius: 8px;
  transition: background-color 0.2s ease;
}

.info-field:hover {
  background-color: rgba(var(--v-theme-primary), 0.05);
}
</style>