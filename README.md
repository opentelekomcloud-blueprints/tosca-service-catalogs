# tosca-service-catalogs

* Collection of service catalogs and templates to import in [Cloud Create](https://docs.otc.t-systems.com/cloud-create/umn/).
* A service catalog is a [software component in TOSCA](https://docs.oasis-open.org/tosca/TOSCA-Simple-Profile-YAML/v1.3/os/TOSCA-Simple-Profile-YAML-v1.3-os.html#DEFN_TYPE_NODES_SOFTWARE_COMPONENT).

## How to contribute?

You can define a service catalog or an application template and send a Pull Request. After your Pull Request is accepted, they will be available in [Cloud Create](https://designer.otc-service.com).

### How to submit an application template?

You can design an application and submit it as a template as follows:

* Clone this repository.
* Create a new folder (e.g., `my_template`) inside the `templates` folder.
* Design an application and click `Download topology`. The application topology will be downloaded as a zip file.

![Fig. Download topology](/images/download-template.png 'Download topology')

* Exact the zip file to the new folder `my_template`.
* Open the file `topology.yml` and update the template with your information.

![Fig. Update topology](/images/update-template.png 'Update topology')

* Create a merge request with tne new `my_template` folder, containing all the files.

### How to define a service catalog?

[See our tutorials](https://docs.designer.otc-service.com/examples/tosca-tutorials/lifecycle_soft_comp)
