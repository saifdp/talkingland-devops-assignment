# DevOps Engineer Assessment - Terraform Deployment

This project demonstrates Infrastructure as Code (IaC) using Terraform to deploy a basic web application stack in AWS.

## Project Structure
devops-assessment/
├── main.tf             # Main infrastructure definition
├── variables.tf        # Variable declarations
├── outputs.tf          # Output definitions
├── userdata.sh         # Nginx installation and configuration script
└── environments/
├── dev.tfvars      # Development environment variables
└── prod.tfvars     # Production environment variables

## Prerequisites

1.  **AWS Account:** You need an active AWS account.
2.  **AWS Credentials:** Configure your AWS credentials.  The recommended method is to use an IAM role if you are running Terraform from an EC2 instance. Otherwise, you can configure the AWS CLI with your access key and secret key:

    ```bash
    aws configure
    ```
3.  **Terraform:** Install Terraform on your local machine.  You can download it from the official Terraform website ([https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html)) and follow the installation instructions for your operating system. Verify the installation:
    ```bash
    terraform --version
    ```
4. **SSH Key Pair (Optional but Strongly Recommended):** Create an SSH key pair in the AWS EC2 console (or using the AWS CLI) in the region you intend to deploy to.  This will allow you to SSH into the EC2 instance.  Note the *name* of your key pair; you'll need it later.

## Deployment Steps

1.  **Clone the Repository (if applicable):**  If the code is in a Git repository, clone it to your local machine:

    ```bash
    git clone <repository_url>
    cd devops-assessment
    ```

2.  **Update AMI IDs (Crucial!):**

    *   Open `environments/dev.tfvars` and `environments/prod.tfvars`.
    *   Find the `ami_id` variable in *both* files.
    *   Replace the placeholder value (e.g., `"ami-0c55t0f18f282d53d"`) with the *correct* AMI ID for your chosen AWS region and operating system (e.g., Amazon Linux 2, Ubuntu).  You can find AMI IDs in the AWS EC2 console ("Launch Instance" wizard) or using the AWS CLI.  Using an incorrect AMI ID will cause the deployment to fail.  This is the *most common* reason for deployment failures.

3.  **Update Key Pair Name (If you want to use ssh):**

    *   Open `environments/dev.tfvars` and `environments/prod.tfvars`.
    *   Find the `key_name` variable in *both* files.
    *   Replace the placeholder value (e.g., `"devops"`) with the *correct* name of key pair that you created before.

4.  **Update AWS Region (Optional):**
    * Open `environments/dev.tfvars` and `environments/prod.tfvars`.
    *   Find the `aws_region` variable in *both* files.
    * You can change these files by the region you want to use.

5. **Initialize Terraform:**

    This command initializes a new or existing Terraform working directory.  It downloads the necessary AWS provider plugins.

    ```bash
    terraform init
    ```

6.  **Plan (Dev Environment):**

    This command creates an execution plan.  It shows you what actions Terraform will take *before* making any changes to your infrastructure.  This is a crucial step for reviewing the planned changes.

    ```bash
    terraform plan -var-file=environments/dev.tfvars
    ```

    Carefully examine the output.  It should list the resources that will be created (EC2 instance, security group).  Look for any errors or warnings.

7.  **Apply (Dev Environment):**

    This command executes the plan and provisions the resources in AWS.

    ```bash
    terraform apply -var-file=environments/dev.tfvars
    ```

    You will be prompted to confirm the deployment. Type `yes` and press Enter.  Terraform will now create the resources. This process may take a few minutes.

8.  **Plan (Prod Environment):**
    Repeat step 6 for the production environment:

    ```bash
      terraform plan -var-file=environments/prod.tfvars
    ```

9.  **Apply (Prod Environment):**
    Repeat step 7 for the production environment:

    ```bash
      terraform apply -var-file=environments/prod.tfvars
    ```

10. **Verify Deployment:**

    After the `apply` command completes successfully, Terraform will display the `public_ip` output (defined in `outputs.tf`).  This is the public IP address of your EC2 instance.

    Open a web browser and navigate to `http://<public_ip>`.  You should see the "Deployed via Terraform" message, indicating that Nginx is running and serving the custom webpage.

11. **SSH Access (Optional):**

    If you configured an SSH key pair and specified it's name in `key_name` variable, you can SSH into the instance using:

    ```bash
    ssh -i <path_to_your_private_key.pem> ec2-user@<public_ip>
    ```

    *   Replace `<path_to_your_private_key.pem>` with the actual path to your private key file.
    *   Replace `ec2-user` with the appropriate username for your AMI (e.g., `ubuntu` for Ubuntu AMIs, `centos` for CentOS AMIs).  Check the AMI documentation if you're unsure.

## Destroying Resources

**Important:**  To avoid ongoing charges, destroy the resources when you are finished with them.

1.  **Destroy (Dev Environment):**

    ```bash
    terraform destroy -var-file=environments/dev.tfvars
    ```

    You will be prompted to confirm. Type `yes` and press Enter.  Terraform will delete all the resources created in the dev environment.

2.  **Destroy (Prod Environment):**

    ```bash
    terraform destroy -var-file=environments/prod.tfvars
    ```
    You will be prompted to confirm. Type `yes` and press Enter. Terraform will delete all the resources created in the prod environment.

