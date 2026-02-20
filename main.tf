# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# Create an Azure Resource Group
resource "azurerm_resource_group" "example" {
  name     = "MyTerraformResourceGroup"
  location = "centralindia"
}
