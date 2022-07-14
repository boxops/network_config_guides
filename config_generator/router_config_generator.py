# Templating engine for generating PE and CPE configurations

# Usage: Change variables in all_variables.yaml file, then run this script
# python3 router_config_generator.py

import yaml, jinja2, os

template_path=os.path.join(os.path.dirname(__file__),'./templates')
templateLoader = jinja2.FileSystemLoader(searchpath=template_path)
templateEnv = jinja2.Environment(loader=templateLoader)

cpe_template_file = "juniper_srx_config_template.txt"
cpe_template = templateEnv.get_template(cpe_template_file)

pe_template_file = "core_config_template.txt"
pe_template = templateEnv.get_template(pe_template_file)

variable_path=os.path.join(os.path.dirname(__file__),'./variables')

variable_file = variable_path + "/all_variables.yml"

configuration_path=os.path.join(os.path.dirname(__file__),'./configurations')


def save_cpe_file(): # Save Customer Premises Equipment (CPE) configuration to a file
    with open(variable_file) as f:
        routers = yaml.safe_load(f)
    for router in routers:
        # For each id in variables, save the configuration to a file
        filename = router['cpe_filename'] + '.txt'
        file = configuration_path + '/' + filename
        with open(file, 'w') as f:
            f.write(cpe_template.render(router))


def print_cpe_conf(): # Print Customer Premises Equipment (CPE) configuration to the terminal
    with open(variable_file) as f:
        routers = yaml.safe_load(f)
    for router in routers:
        # For each id in variables, print the configuration to the terminal
        filename = router['cpe_filename']
        print("-"*40 + " Start of CPE Configuration for " + filename + " " + "-"*40)
        print(cpe_template.render(router))
        print("-"*40 + " End of CPE Configuration for " + filename + " " + "-"*40)


def save_pe_file(): # Save Provider Edge (PE) configuration to a file
    with open(variable_file) as f:
        routers = yaml.safe_load(f)
    for router in routers:
        # For each id in variables, save the configuration to a file
        filename = router['pe_filename'] + '.txt'
        file = configuration_path + '/' + filename
        with open(file, 'w') as f:
            f.write(pe_template.render(router))


def print_pe_conf(): # Print Provider Edge (PE) configuration to the terminal
    with open(variable_file) as f:
        routers = yaml.safe_load(f)
    for router in routers:
        # For each id in variables, print the configuration to the terminal
        filename = router['pe_filename']
        print("-"*40 + " Start of PE Configuration for " + filename + " " + "-"*40)
        print(pe_template.render(router))
        print("-"*40 + " End of PE Configuration for " + filename + " " + "-"*40)


# save_cpe_file()
print_cpe_conf()

# save_pe_file()
print_pe_conf()
