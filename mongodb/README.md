# otc.nodes.SoftwareComponent.MongoDB

## About

Use this component to deploy a MongoDB with replication and create MongoDB users.

## How to use

### How to deploy a sinple MongoDB?

* Put the component **MongoDBPrimary** on a compute node.

### How to deploy a MongoDB cluster?

* To enable replication, select **MongoDBPrimary** and specify the replication set name in the property **replication_replset** (e.g., `rs0`).
* Put the component **MongoDBSecondary** on a compute node.
* Connect **MongoDBSecondary** to **MongoDBPrimary** using the **join_primary** relationship.

![Fig. MongoDB Cluster](../topology/mongodb-cluster/join_primary.png 'MongoDB Cluster')

* Create a security group (e.g., `sgMongo`) to allow incoming traffic to port `27017` and assign it to the compute nodes.

![Fig. MongoDB Cluster](../topology/mongodb-cluster/image.png 'MongoDB Cluster')

Expected result: **MongoDBPrimary** is created first and init the relication set `rs0`. When **MongoDBSecondary** is up, it will join the replication set. In particular, MongoDBSecondary connects to the private IP address of MongoDBPrimary on port `27017` and registers its private IP address to the relication set.

### How to deploy a MongoDB cluster with keyfile authentication

* Generate a keyfile content with the command `openssl rand -base64 741`.
* Select **MongoDBPrimary** and enable the property **security_authorization**.
* Specify the property **replication_keyfile_content** with the generated keyfile content.

Expected result: The keyfile is created at `/etc/mongodb-keyfile` on each MongoDB instances for inter-authentication.

### How to create MongoDB users?

* Select **MongoDBPrimary** and enable the property **security_authorization**.
* Specify the property **root_admin_name** / **root_admin_password** to create the root user (TODO use `get_secret` to specify a secret).
* (Optional) specify the property **mongodb_users** to create normal users with a given role in a given database.

![Fig. MongoDB Cluster](../topology/mongodb-cluster/property.png 'MongoDB Cluster')

## Example

* See [topology example](../topology/mongodb-cluster/toplogy.yml "Topology example").