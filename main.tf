resource "azurerm_resource_group" "terraformgroup" {
  name     = "TEST-RG"
  location = "CentralIndia"
}
# Create virtual network
resource "azurerm_virtual_network" "terraformnetwork" {
  name                = "Test-Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "SouthIndia"
  resource_group_name = azurerm_resource_group.terraformgroup.name
}
# Create subnet
resource "azurerm_subnet" "terraformsubnet" {
  name                 = "TestSubnet"
  resource_group_name  = azurerm_resource_group.terraformgroup.name
  virtual_network_name = azurerm_virtual_network.terraformnetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Create public IPs
resource "azurerm_public_ip" "terraformpublicip" {
  name                = "TestPublicIP"
  location            = "CentralIndia"
  resource_group_name = azurerm_resource_group.terraformgroup.name
  allocation_method   = "Static"
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "terraformnsg" {
  name                = "TestNetworkSecurityGroup"
  location            = "CentralIndia"
  resource_group_name = azurerm_resource_group.terraformgroup.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "80", "443", "32323"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
# Create network interface
resource "azurerm_network_interface" "terraformnic" {
  name                = "TestNIC"
  location            = "SouthIndia"
  resource_group_name = azurerm_resource_group.terraformgroup.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.terraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terraformpublicip.id
  }
}
# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.terraformnic.id
  network_security_group_id = azurerm_network_security_group.terraformnsg.id
}
# Create virtual machine
resource "azurerm_linux_virtual_machine" "terraformvm" {
  name                  = "myVM"
  location              = "SouthIndia"
  resource_group_name   = azurerm_resource_group.terraformgroup.name
  network_interface_ids = [azurerm_network_interface.terraformnic.id]
  size                  = "Standard_A2_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "Windows@123456"
  disable_password_authentication = false
}
