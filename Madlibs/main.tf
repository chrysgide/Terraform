terraform {
  required_version = ">= 0.15"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    # Le provider random permet générer de façon aléatoires des chaines de caractères, ids, ... 
    random = {
      source  = "hashicorp/random"
      version = "~> 2.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}
# resource "local_file" "literature" {
#   filename = "book.txt"
#   content  = <<-EOT
#         Sun Tzu said: The art of war is of vital importance to the State.
#         It is a matter of life and death, a road either to safety or to
#         ruin. Hence it is a subject of inquiry which can on no account be
#         neglected.
#     EOT

# }

locals {
  #syntax of a "for" expression that uppercases each word in a list
  # [ for s in ["cat","milk","sun"] : upper(s)]
  # syntax to uppercase an object.
  uppercase_words = { for k, v in var.words : k => [for s in v : upper(s)] }

  #If you want to filter out a particular key, you can do so with the "if" clause
  #{for k,v in var.words : k => [for s in v : upper(s)] if k != "numbers"}
}


# Le provider Random de Terraform introduit une ressource "random_shuffle" pour
# mélanger les listes en toute sécurité, c'est donc ce que nous allons utiliser. Puisque nous avons cinq listes, nous avons besoin de cinq
# random_shuffles
resource "random_shuffle" "random_nouns" {
  count = var.num_files
  input = local.uppercase_words["nouns"]
}
resource "random_shuffle" "random_adjectives" {
  count = var.num_files
  input = local.uppercase_words["adjectives"]
}
resource "random_shuffle" "random_verbs" {
  count = var.num_files
  input = local.uppercase_words["verbs"]
}
resource "random_shuffle" "random_adverbs" {
  count = var.num_files
  input = local.uppercase_words["adverbs"]
}
resource "random_shuffle" "random_numbers" {
  count = var.num_files
  input = local.uppercase_words["numbers"]
}

locals {
  templates = tolist(fileset(path.module, "templates/*.txt"))
}

resource "local_file" "mad_libs" {
  count    = var.num_files
  filename = "madlibs/madlibs-${count.index}.txt"
  content = templatefile(element(local.templates, count.index),
    {
      nouns      = random_shuffle.random_nouns[count.index].result
      adjectives = random_shuffle.random_adjectives[count.index].result
      verbs      = random_shuffle.random_verbs[count.index].result
      adverbs    = random_shuffle.random_adverbs[count.index].result
      numbers    = random_shuffle.random_numbers[count.index].result
  })

}

# Cette data "archive_file" provenant du provider "archive" va nous permettre de ziper tous nos fichiers générer par
# la ressource "local_file"
data "archive_file" "mad_libs" {
  depends_on = [
    local_file.mad_libs
  ]
  type        = "zip"
  source_dir  = "${path.module}/madlibs"
  output_path = "${path.module}/madlibs.zip"
}
# output "mad_libs" {
#   value = templatefile("${path.module}/templates/alice.txt", {
#     nouns      = random_shuffle.random_nouns.result
#     adjectives = random_shuffle.random_adjectives.result
#     verbs      = random_shuffle.random_verbs.result
#     adverbs    = random_shuffle.random_adverbs.result
#     numbers    = random_shuffle.random_numbers.result
#   })

# }

