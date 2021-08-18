
resource vsphere_role "role1" {
  name = "anthos"
  role_privileges = ["Alarm.Acknowledge", "Alarm.Create", "Datacenter.Create", "Datacenter.Move"]
}

