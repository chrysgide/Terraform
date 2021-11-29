variable "words" {
  description = "A word pool to use for Mad Libs"
  type = object({
    nouns      = list(string),
    adjectives = list(string),
    verbs      = list(string),
    adverbs    = list(string),
    numbers    = list(number)
  })

  validation {
    condition     = length(var.words["nouns"]) >= 5
    error_message = "You must provide at least 5 nouns."
  }
  validation {
    condition     = length(var.words["adjectives"]) >= 5
    error_message = "You must provide at least 5 adjectives."
  }
  validation {
    condition     = length(var.words["verbs"]) >= 5
    error_message = "You must provide at least 5 verbs."
  }
  validation {
    condition     = length(var.words["adverbs"]) >= 5
    error_message = "You must provide at least 5 adverbs."
  }
  validation {
    condition     = length(var.words["numbers"]) >= 5
    error_message = "You must provide at least 5 numbers."
  }

}
