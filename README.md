Creating the new VPC , public and private subnets, IGW, Routes, Route Association, NAT Gateways, Private subnet, Route table and Route Table Association


# Things to understand :

## Public Subnet :

A subnet is just an IP range inside your VPC. It becomes public only if:
Its route table has a default route (0.0.0.0/0) pointing to the Internet Gateway (IGW).

So in a public subnet:
EC2 instances (with a public IP or EIP) can talk directly to the internet.
Example: Load Balancers, Bastion Hosts, NAT Gateway usually go here.

## Private Subnet:

A subnet is private if:
It does not have a route to the IGW.
Instead, its default route points to the NAT Gateway in the public subnet.
So in a private subnet:
Instances cannot receive inbound traffic directly from the internet.
But they can initiate outbound traffic (like yum update, apt upgrade, download software, pull Docker images, etc.) via the NAT.

Example: Databases, application servers, internal microservices live here.

## Subnet IPs
When you create a subnet in a VPC (say 10.0.1.0/24), AWS assigns private IP addresses from that range.
Example: 10.0.1.5, 10.0.1.10 etc.
These never leave AWS privately — they are not internet-routable.
Even if the subnet is called public, those IPs are still private IPs.
What makes the subnet public is that it has a route 0.0.0.0/0 → IGW, allowing resources in it to be reachable if they also have a public IP.

## Public IPs (Dynamic)
If you launch an EC2 in a public subnet and enable auto-assign public IP, AWS gives it a temporary public IP from its pool.
This is not stable:
Stops/starts of the instance → new public IP.
Behind the scenes: AWS maps
Public IP - Private IP (e.g., 3.110.x.x → 10.0.1.5)

## Elastic IP (EIP)
An Elastic IP is a static public IPv4 address that belongs to your AWS account.
It’s not tied to your subnet’s CIDR.
Think of it as: AWS has a huge global pool of public IPv4 addresses (outside VPC ranges).
When you allocate an EIP, you reserve one of those IPs.
Then you associate it with a resource (EC2, NAT Gateway, etc).

Now traffic goes like:
EIP (say 13.234.x.x) - Private IP in Subnet (10.0.1.5)

## Route:

Route gives the destination to reach .
A route in a Route Table tells AWS:
For traffic going to this destination (CIDR block), forward it to this target.

Target can be local, IGW, NAT, Network interface, VPN Gateway and VPC peering 


Public Subnet → 0.0.0.0/0 → IGW → Internet
Private Subnet → 0.0.0.0/0 → NAT (in Public Subnet) → IGW → Internet
Isolated Subnet → NO 0.0.0.0/0 → stays internal

## IGW:

Internet gateway enables communication between public subnet to outside Internet in a VPN.
In a VPN , default one IGW will be there .
0.0.0.0/0 Is the route value for IGW in public subnet 


## NAT Gateway:

It helps the private subnets to reach the outside world. 
NAT gateways are placed in public subnet . It always needs an EIP to communicate to outside world they IGW

For ec2 instance, by default we will get 2 IPs . Internal and external . Internal for internal communication and external for internet communication.
NAT gateways wont get External IPs. So we must assiciate an EIP to it , to communicate to internet thru IGW

Working :
NAT Gateway placement

You must create the NAT Gateway inside a public subnet.
In that subnet, the NAT Gateway gets:

One private IP (like 10.0.1.5) from the subnet’s CIDR range.

Elastic IP (EIP) attachment:

By default, that private IP cannot talk to the internet.
So AWS forces you to attach an Elastic IP (EIP) → this gives the NAT Gateway a permanent public IPv4 address (like 3.95.12.45).

## Route setup:

In your private subnets’ route tables, the default route (0.0.0.0/0) points to the NAT Gateway.
So when an EC2 in a private subnet tries to connect to the internet (say yum update):
It sends the traffic → NAT Gateway (private IP).
NAT Gateway translates private → Elastic IP.
Sends it out via the Internet Gateway (IGW).
Reply comes back to the EIP, NAT translates again → sends to private EC2.

## EIP: Elatic Ips

They doesnot belong to any subnets . 
They are provided from AWS Ip pool to comminicate to outside world

An EIP (Elastic IP) is not tied to a subnet.
It’s an AWS-managed public IPv4 address that you can associate with: NAT Gateway, Load balancer


## Why must NAT Gateway be in a public subnet?

A public subnet is any subnet with a route to the Internet Gateway (IGW).
When you place the NAT GW there, AWS can:
Give it a private IP from that subnet (like 10.0.1.25)
Bind your EIP (say 3.95.12.45) to that private IP
Route internet traffic through the IGW (because the subnet has 0.0.0.0/0 → IGW)


### Complete flow :

How the pieces fit together

Private subnet:
Route table: 0.0.0.0/0 → NAT Gateway
EC2s have only private IPs

NAT Gateway (in public subnet):
Private IP (from subnet CIDR, e.g. 10.0.1.25)
Public IP (EIP, e.g. 3.95.12.45)
Subnet has route 0.0.0.0/0 → IGW

Internet Gateway (IGW):
Handles actual communication between EIP and the outside world






## Locals :

Locals are a way to define local values (local variables) inside your configuration.

They are like temporary named values that you can reuse in your Terraform code to make it cleaner, more maintainable, and avoid repetition.

<img width="976" height="270" alt="image" src="https://github.com/user-attachments/assets/5d09636b-9fd0-4cdb-a333-142ddb05ca03" />
<img width="1056" height="558" alt="image" src="https://github.com/user-attachments/assets/4dca883a-ba24-4fb1-8cd3-aaca780a4cd2" />

<img width="874" height="474" alt="image" src="https://github.com/user-attachments/assets/cee3e9ee-f704-405e-b7b9-137d1ded26cc" />



<img width="1362" height="713" alt="image" src="https://github.com/user-attachments/assets/1d492483-ebb3-4927-a90f-c8099419b91f" />


## We will install the public subnets, Routes and IGW

### Adding the local variables for the public subnets


<img width="1024" height="399" alt="image" src="https://github.com/user-attachments/assets/51e000ae-be13-40c4-b490-809347f9c23e" />

### Adding the IGW using local variables created 

<img width="897" height="436" alt="image" src="https://github.com/user-attachments/assets/284324b8-96b6-4f91-a4ac-63c162c9f8ae" />

### Adding the public subnets
Create 2 public subnets inside my VPC (aws_vpc.main) — one in ap-south-1a and one in ap-south-1b. Give them CIDRs from local.public_subnets, assign them names, and mark them for Kubernetes load balancers (for future use)

<img width="1388" height="466" alt="image" src="https://github.com/user-attachments/assets/eee97a3f-16f7-4cf3-ab0f-ab3a7e6dca05" />

### Adding the Public Routes :

Creates 1 public route table with a default route → internet gateway.

Associates this route table with all public subnets (in local.public_subnets).

Result:

Any EC2 instance launched in those subnets can reach the internet.

Because we set map_public_ip_on_launch = true earlier, EC2 instances in those subnets will also get public IPs, so they are accessible from the internet too.

<img width="1345" height="635" alt="image" src="https://github.com/user-attachments/assets/1a671cd0-d766-43f3-90cb-4c0624bffed7" />


Terraform plan

<img width="1445" height="1049" alt="image" src="https://github.com/user-attachments/assets/17280543-a77a-46f3-87aa-dc64757ce161" />
<img width="1519" height="854" alt="image" src="https://github.com/user-attachments/assets/5374cd82-9d2f-46e1-b63d-c43ce99b8fd5" />

Terraform apply

<img width="1136" height="1086" alt="image" src="https://github.com/user-attachments/assets/a39182f9-cd17-4188-a812-1aea4a60ce6d" />
<img width="1620" height="612" alt="image" src="https://github.com/user-attachments/assets/3a236f20-8e8f-4251-9a9d-a85b430f1092" />

A VPC, 2 Public subnets, IGW , Routes and Route association to Public Subnets

<img width="1620" height="612" alt="image" src="https://github.com/user-attachments/assets/25bb06db-1d75-4088-8389-fb507864d45d" />


## Validating in Console :


### VPC created:

<img width="1911" height="965" alt="image" src="https://github.com/user-attachments/assets/b116124b-f18c-4c1a-9270-19e5fc4df469" />

### Resource Map:

<img width="1581" height="595" alt="image" src="https://github.com/user-attachments/assets/5d03812e-7689-4918-9166-f3482606fd1d" />

### 2 Public Subnet :

<img width="1916" height="459" alt="image" src="https://github.com/user-attachments/assets/3ad1f8ac-c70c-46e6-bf71-1ede18a29173" />


<img width="1913" height="922" alt="image" src="https://github.com/user-attachments/assets/f652c1f3-a72d-4bf2-8f02-dd3be349d614" />

<img width="1904" height="948" alt="image" src="https://github.com/user-attachments/assets/926b701c-18d4-4188-a8a6-5c4c18ee0713" />

### Route table for 2 public subnet:

<img width="1882" height="901" alt="image" src="https://github.com/user-attachments/assets/088a104f-2068-4dae-8342-c66434b42b79" />

<img width="1914" height="952" alt="image" src="https://github.com/user-attachments/assets/bf9be0ec-4107-4bc0-8ec5-066cf06615ed" />

### IGW:

<img width="1920" height="943" alt="image" src="https://github.com/user-attachments/assets/758d2518-6963-4d5f-87c1-198f294f47ff" />


## Adding the private Routes

### Creating NAT GW
NAT GW will be placed in public subnet ( all subnets in public and private are obviously private) . As they need Real IP from AWS pool to communicate to external World. We are assigning an EIP

<img width="1479" height="653" alt="image" src="https://github.com/user-attachments/assets/040b7b67-6558-4875-80ae-80383474efbf" />










