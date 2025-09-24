# ☑️ EC2 Setup con Terraform

Questa guida documenta i passaggi per avviare un'istanza EC2 su AWS usando Terraform, con provisioning automatico e accesso via SSH. Include anche la procedura per distruggere l'infrastruttura.

---

## 🔢 Prerequisiti

* [Terraform](https://developer.hashicorp.com/terraform/downloads) installato
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configurato (`aws configure`)
* Accesso a un account AWS con permessi su EC2
* Chiave SSH `.pem` generata e disponibile (es: `gamecloud-key.pem`)

---

## 📁 Struttura del progetto

```
terraform/
├── ec2.tf               # Definizione risorsa EC2
├── provider.tf          # Configurazione provider AWS
├── variables.tf         # Variabili dichiarate
├── terraform.tfvars     # Valori delle variabili
├── outputs.tf           # Output dell'infrastruttura
└── gamecloud-key.pem    # Chiave privata per SSH
```

---

## ⚙️ Setup EC2

### 1. Inizializza Terraform

```bash
terraform init
```

### 2. Applica la configurazione

```bash
terraform apply
```

> Conferma con `yes` quando richiesto. Alla fine, verrà mostrato l’IP pubblico dell’istanza.

---

## 🔑 Connessione SSH

### 1. Imposta permessi corretti sul file `.pem`

```bash
chmod 400 gamecloud-key.pem
```

### 2. Connettiti alla macchina

```bash
ssh -i "gamecloud-key.pem" ubuntu@<IP_PUBLICO>
```

Esempio:

```bash
ssh -i "gamecloud-key.pem" ubuntu@54.74.155.119
```

---

## ⏹️ Spegnere o Distruggere l’istanza

### Spegnere (senza distruggere)

Accedi via SSH e usa:

```bash
sudo shutdown now
```

Oppure usa la console AWS per “Stop Instance”.

### Distruggere completamente

```bash
terraform destroy
```

> ⚠️ Questo comando rimuove tutte le risorse create con Terraform.

---

## 🔒 Esempio di Policy IAM per EC2

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "iam:PassRole",
        "ssm:*",
        "cloudwatch:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## 📝 Note

* **Non** committare mai il file `.pem` nel repository.
* Anche un’istanza “ferma” può generare costi per l’EBS.
* Per evitare spese indesiderate, esegui sempre `terraform destroy` quando hai
