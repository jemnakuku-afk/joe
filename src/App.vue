<template>
  <v-app>
    <v-app-bar color="primary" prominent class="modern-app-bar">
      <v-app-bar-nav-icon @click="drawer = !drawer"></v-app-bar-nav-icon>
      
      <v-toolbar-title class="text-h5 font-weight-bold">
        <v-icon class="mr-2">mdi-school</v-icon>
        EP MATENDO - Gestion Inscriptions
      </v-toolbar-title>

      <v-spacer></v-spacer>

      <v-btn 
        icon 
        @click="$router.push('/')"
        class="nav-btn"
      >
        <v-icon>mdi-view-dashboard</v-icon>
      </v-btn>
      
      <v-btn 
        icon 
        @click="toggleTheme"
        class="nav-btn ml-2"
      >
        <v-icon>{{ isDark ? 'mdi-weather-sunny' : 'mdi-weather-night' }}</v-icon>
      </v-btn>
    </v-app-bar>

    <v-navigation-drawer 
      v-model="drawer" 
      temporary
      class="modern-drawer"
    >
      <div class="drawer-header pa-4 bg-primary">
        <div class="text-h6 text-white font-weight-bold">
          <v-icon class="mr-2" color="white">mdi-school</v-icon>
          EP MATENDO
        </div>
        <div class="text-body-2 text-blue-lighten-3">
          Système de gestion
        </div>
      </div>
      
      <v-list>
        <v-list-item
          prepend-icon="mdi-view-dashboard"
          title="Tableau de bord"
          @click="$router.push('/')"
          class="nav-item"
        ></v-list-item>
        
        <v-list-item
          prepend-icon="mdi-account-plus"
          title="Inscription"
          @click="$router.push('/inscription')"
          class="nav-item"
        ></v-list-item>
        
        <v-list-item
          prepend-icon="mdi-account-tie"
          title="Secrétariat"
          @click="$router.push('/secretariat')"
          class="nav-item"
        ></v-list-item>
        
        <v-divider class="my-2"></v-divider>
        
        <v-list-item
          prepend-icon="mdi-chart-line"
          title="Statistiques"
          @click="$router.push('/stats')"
          class="nav-item"
        ></v-list-item>
        
        <v-list-item
          prepend-icon="mdi-cog"
          title="Paramètres"
          @click="$router.push('/settings')"
          class="nav-item"
        ></v-list-item>
      </v-list>
    </v-navigation-drawer>

    <v-main>
      <router-view class="page-transition" />
    </v-main>

    <v-footer color="grey-lighten-3" class="text-center modern-footer">
      <div>
        <v-icon class="mr-1" size="16">mdi-copyright</v-icon>
        2025 EP MATENDO - Système de Gestion des Inscriptions
        <v-chip size="x-small" color="success" class="ml-2">v2.0</v-chip>
      </div>
    </v-footer>
  </v-app>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useTheme } from 'vuetify'

const theme = useTheme()
const drawer = ref(false)
const isDark = ref(false)

function toggleTheme() {
  isDark.value = !isDark.value
  theme.global.name.value = isDark.value ? 'dark' : 'light'
}
</script>

<style scoped>
.modern-app-bar {
  backdrop-filter: blur(10px);
  background: linear-gradient(135deg, var(--v-theme-primary) 0%, var(--v-theme-secondary) 100%) !important;
}

.nav-btn {
  transition: all 0.3s ease;
}

.nav-btn:hover {
  transform: scale(1.1);
  background-color: rgba(255, 255, 255, 0.1);
}

.modern-drawer {
  border-radius: 0 16px 16px 0;
}

.drawer-header {
  background: linear-gradient(135deg, var(--v-theme-primary) 0%, var(--v-theme-secondary) 100%);
}

.nav-item {
  margin: 4px 8px;
  border-radius: 12px;
  transition: all 0.3s ease;
}

.nav-item:hover {
  background-color: rgba(var(--v-theme-primary), 0.1);
  transform: translateX(4px);
}

.page-transition {
  animation: fadeInUp 0.6s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modern-footer {
  backdrop-filter: blur(10px);
  background: rgba(255, 255, 255, 0.9);
}
</style>