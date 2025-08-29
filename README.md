

Locals :

Locals are a way to define local values (local variables) inside your configuration.

They are like temporary named values that you can reuse in your Terraform code to make it cleaner, more maintainable, and avoid repetition.

<img width="976" height="270" alt="image" src="https://github.com/user-attachments/assets/5d09636b-9fd0-4cdb-a333-142ddb05ca03" />
<img width="980" height="528" alt="image" src="https://github.com/user-attachments/assets/ca02d4c5-b0cb-40d2-929d-d3f3c5853384" />
<img width="874" height="474" alt="image" src="https://github.com/user-attachments/assets/cee3e9ee-f704-405e-b7b9-137d1ded26cc" />



<img width="1362" height="713" alt="image" src="https://github.com/user-attachments/assets/1d492483-ebb3-4927-a90f-c8099419b91f" />


We will install the public subnets, Routes and IGW

Adding the local variables for the public subnets


<img width="1024" height="399" alt="image" src="https://github.com/user-attachments/assets/51e000ae-be13-40c4-b490-809347f9c23e" />

Adding the IGW using local variables created 

<img width="897" height="436" alt="image" src="https://github.com/user-attachments/assets/284324b8-96b6-4f91-a4ac-63c162c9f8ae" />

Adding the public subnets
Create 2 public subnets inside my VPC (aws_vpc.main) — one in ap-south-1a and one in ap-south-1b. Give them CIDRs from local.public_subnets, assign them names, and mark them for Kubernetes load balancers (for future use)

<img width="1388" height="466" alt="image" src="https://github.com/user-attachments/assets/eee97a3f-16f7-4cf3-ab0f-ab3a7e6dca05" />

Adding the Public Routes :

Creates 1 public route table with a default route → internet gateway.

Associates this route table with all public subnets (in local.public_subnets).

Result:

Any EC2 instance launched in those subnets can reach the internet.

Because we set map_public_ip_on_launch = true earlier, EC2 instances in those subnets will also get public IPs, so they are accessible from the internet too.

<img width="1345" height="635" alt="image" src="https://github.com/user-attachments/assets/1a671cd0-d766-43f3-90cb-4c0624bffed7" />










