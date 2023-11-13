import FormGroupInput from "./Inputs/formGroupInput.vue";
import FormGroupSelect from "./Inputs/formGroupSelect.vue";

import Content from "./Content.vue"
import Footer from "./ContentFooter.vue";

import DropDown from "./Dropdown.vue";
import PaperTable from "./PaperTable.vue";
import Button from "./Button";

import Card from "./Cards/Card.vue";
import ChartCard from "./Cards/ChartCard.vue";
import StatsCard from "./Cards/StatsCard.vue";

import SidebarPlugin from "./SidebarPlugin/index";

let components = {
  FormGroupInput,
  FormGroupSelect,
  Card,
  ChartCard,
  StatsCard,
  PaperTable,
  DropDown,
  SidebarPlugin,
  Content,
  Footer,
};

export default components;

export {
  FormGroupInput,
  FormGroupSelect,
  Card,
  ChartCard,
  StatsCard,
  PaperTable,
  DropDown,
  Button,
  SidebarPlugin,
  Content,
  Footer,
};
