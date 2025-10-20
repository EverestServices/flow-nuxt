import js from "@eslint/js";
import globals from "globals";
import tseslint from "typescript-eslint";
import pluginVue from "eslint-plugin-vue";
import pluginNuxt from "eslint-plugin-nuxt";
import vueParser from "vue-eslint-parser";

const nuxtRecommended = pluginNuxt.configs["flat/recommended"];
const vueEssential = pluginVue.configs["flat/essential"];

export default [
  {
    languageOptions: {
      globals: { ...globals.browser, ...globals.node },
    },
  },
  js.configs.recommended,
  ...(Array.isArray(vueEssential) ? vueEssential : vueEssential ? [vueEssential] : []),
  ...(Array.isArray(nuxtRecommended) ? nuxtRecommended : nuxtRecommended ? [nuxtRecommended] : []),
  ...tseslint.configs.recommended,
  {
    ignores: ["**/.nuxt/**", "**/.output/**", "**/dist/**"],
  },
  {
    files: ["**/*.vue"],
    languageOptions: {
      parser: vueParser,
      parserOptions: {
        parser: tseslint.parser,
        ecmaVersion: "latest",
        sourceType: "module",
        extraFileExtensions: [".vue"],
      },
    },
  },
  {
    files: ["app/**/*.{ts,vue}"],
    languageOptions: {
      globals: {
        definePageMeta: true,
        useRouter: true,
        useRoute: true,
        navigateTo: true,
        useRuntimeConfig: true,
        useState: true,
        useFetch: true,
        useAsyncData: true,
        useSupabaseClient: true,
        useSupabaseUser: true,
      },
    },
    rules: {
      "no-undef": "off",
      "@typescript-eslint/no-explicit-any": "off",
      "@typescript-eslint/no-unused-vars": "off",
      "no-case-declarations": "off"
    },
  },
  {
    files: [
      "app/pages/**/*.vue",
      "app/layouts/**/*.vue",
      "app/error.vue",
      "app/components/**/*.vue"
    ],
    rules: {
      "vue/multi-word-component-names": "off",
      "vue/no-mutating-props": "off",
    },
  },
];
