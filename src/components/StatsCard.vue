<template>
  <v-card 
    class="stats-card" 
    :color="color" 
    variant="tonal"
    elevation="3"
  >
    <v-card-text class="pa-6">
      <div class="d-flex align-center justify-space-between mb-3">
        <v-icon :size="40" :color="color" class="stats-icon">
          {{ icon }}
        </v-icon>
        
        <v-chip 
          :color="getTrendColor(trend)" 
          size="small" 
          variant="tonal"
          class="trend-chip"
        >
          <v-icon size="12" class="mr-1">
            {{ getTrendIcon(trend) }}
          </v-icon>
          {{ trend }}
        </v-chip>
      </div>
      
      <div class="stats-content">
        <div class="text-h4 font-weight-bold mb-1">
          {{ value }}
        </div>
        <div class="text-body-2 text-grey-darken-1">
          {{ title }}
        </div>
      </div>
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
interface Props {
  title: string
  value: string | number
  icon: string
  color: string
  trend?: string
}

defineProps<Props>()

function getTrendColor(trend?: string): string {
  if (!trend) return 'grey'
  return trend.startsWith('+') ? 'success' : trend.startsWith('-') ? 'error' : 'grey'
}

function getTrendIcon(trend?: string): string {
  if (!trend) return 'mdi-minus'
  return trend.startsWith('+') ? 'mdi-trending-up' : trend.startsWith('-') ? 'mdi-trending-down' : 'mdi-minus'
}
</script>

<style scoped>
.stats-card {
  border-radius: 16px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.stats-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, var(--v-theme-primary), var(--v-theme-secondary));
  opacity: 0;
  transition: opacity 0.3s ease;
}

.stats-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15) !important;
}

.stats-card:hover::before {
  opacity: 1;
}

.stats-icon {
  transition: transform 0.3s ease;
}

.stats-card:hover .stats-icon {
  transform: scale(1.1);
}

.trend-chip {
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.stats-content {
  animation: fadeInUp 0.6s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>