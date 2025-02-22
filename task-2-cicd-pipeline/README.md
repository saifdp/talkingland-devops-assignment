## Deployment Steps

1.  **Clone the Repository:**

    ```bash
    git clone <your-repository-url>
    cd my-nodejs-app
    ```

2.  **Create ECR Repository:**

    If you don't already have an ECR repository, create one via the AWS Management Console or the AWS CLI:

    ```bash
    aws ecr create-repository --repository-name my-nodejs-app-repo --region <your-aws-region>
    ```
    Replace `<your-aws-region>` with your AWS region (e.g., `us-east-1`).  Note the repository URI.

3.  **Create EKS Cluster:**

      If you don't already have an EKS cluster, create it via the AWS management console, eksctl, or terraform.

4.  **Configure `kubectl`:**

    Ensure `kubectl` is configured to connect to your EKS cluster. You can typically do this with:

    ```bash
    aws eks update-kubeconfig --name <your-eks-cluster-name> --region <your-aws-region>
    ```

5.  **Update Placeholders:**

    *   **`Dockerfile`:** No changes are typically needed if you're using the provided example.
    *   **`buildspec.yml`:** No changes are typically needed, the environment variables will be configured in CodePipeline.
    *   **`buildspec-deploy.yml`:**
        *   Replace `YOUR_EKS_CLUSTER_NAME` and `YOUR_AWS_REGION` with your actual EKS cluster name and region.
    *   **`kubernetes/deployment.yaml`:**
        *   Replace `<YOUR_ECR_IMAGE_URI>` with the full URI of your ECR repository and image (e.g., `123456789012.dkr.ecr.us-east-1.amazonaws.com/my-nodejs-app-repo:latest`).  *However*, CodePipeline will handle injecting the correct image URI, so it's best to *leave this as a placeholder* and let CodePipeline handle it via the `imagedefinitions.json` file.
    *   **`kubernetes/service.yaml`:** No changes are typically needed if you're using the provided example.

6.  **Create CodePipeline:**

    *   Go to the AWS CodePipeline console.
    *   Create a new pipeline.
    *   **Source Stage:**
        *   Choose your source provider (GitHub, CodeCommit, etc.).
        *   Connect to your repository and select the branch.
    *   **Build Stage (Image Build):**
        *   Choose AWS CodeBuild.
        *   Create a new CodeBuild project.
        *   Use the `buildspec.yml` file.
        *   Set environment variables:
            *   `AWS_REGION`: Your AWS region.
            *   `AWS_ACCOUNT_ID`: Your AWS account ID.
            *   `IMAGE_REPO_NAME`: Your ECR repository name (e.g., `my-nodejs-app-repo`).
            *   `IMAGE_TAG`:  `latest` (or better, use `$CODEBUILD_RESOLVED_SOURCE_VERSION` to use the Git commit hash).
        *   Ensure the CodeBuild service role has permissions to access ECR.
    *   **Deploy Stage (EKS Deployment):**
        *   Add a *new* build stage (using CodeBuild).
        *   Create a *new* CodeBuild project.
        *   Use the `buildspec-deploy.yml` file.
        *   Ensure the CodeBuild service role for this stage has permissions to interact with your EKS cluster.  This is *critical*. Attach the necessary IAM policies (see detailed instructions in previous responses).

7.  **Trigger the Pipeline:**

    Once the pipeline is created, it will automatically start when you push changes to your source repository.  You can also manually start the pipeline from the CodePipeline console.

8. **Verify Deployment**
   *  After deployment, use `kubectl get pods,svc -n <your-namespace>` (replace `<your-namespace>` with `default` if you are not using namespaces, or with the namespace where you deployed) to verify that your application is running.
   * Get the external IP or hostname of LoadBalancer: `kubectl get svc my-nodejs-app-service -n <your-namespace>`
   *   If using Minikube, use `minikube service my-nodejs-app-service -n <your-namespace>` to get a URL to access your application.
   *   If using Kind, use port forwarding: `kubectl port-forward svc/my-nodejs-app-service 8080:80 -n <your-namespace>` and then access `http://localhost:8080`.

## Rollback

To rollback to a previous version:

1.  Find the deployment history: `kubectl rollout history deployment/my-nodejs-app-deployment -n <your-namespace>`
2.  Rollback to a specific revision: `kubectl rollout undo deployment/my-nodejs-app-deployment --to-revision=<revision_number> -n <your-namespace>`

