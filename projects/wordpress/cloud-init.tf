data "cloudinit_config" "cloud-config" {
  gzip          = false
  base64_encode = false

  # Main cloud-config configuration file.
  part {
    filename     = "cloud-config.yaml"
    content      = base64decode("I2Nsb3VkLWNvbmZpZwpwYWNrYWdlX3VwZGF0ZTogdHJ1ZQpwYWNrYWdlczoKICAtIGJhc2gtY29tcGxldGlvbgogIC0gdW56aXAKdXNlcnM6CiAgLSBuYW1lOiBkcmV3CiAgICBzdWRvOiBbJ0FMTD0oQUxMKSBOT1BBU1NXRDpBTEwnXQogICAgZ3JvdXBzOiBbc3Vkbywgd3d3LWRhdGFdCiAgICBzaGVsbDogL2Jpbi9iYXNoCiAgICBsb2NrX3Bhc3N3ZDogZmFsc2UKICAgIHBhc3N3ZDogJDYkcm91bmRzPTQwOTYkblFFZWFIdHJqaVVseE9QaSRMUWxnaTBYQlI2dTQ2QUpGaFd4c1dCQks4WXFIYkdXWVdrV25HLllobWRZa2MvbE1pQWFjTXdRQWJaMFc3TW9zTEZleHVzaEhRcGZhMDVlRzdnc0wvMQogICAgc3NoLWF1dGhvcml6ZWQta2V5czoKICAgICAgLSBzc2gtcnNhIEFBQUFCM056YUMxeWMyRUFBQUFEQVFBQkFBQUJBUUNYM1pubm9qU3BxaTFSN0NXbVA3dVZGVTJmRWQydVM0UFlRcFdDMjNTY21ER1A3S0ZIZVRKZk1jNmVNYUFoYnhmSVh4MkNGZHNJaFA1VTU4QkZMbUF4a1VJTThsR25IZ2gxdU1FL2FPTVpva1pyRGhZbncwZWFhbVZPZzByZEtEL3VhVG84N0FTb3hwZjBYWW5ycWNyWWhGSVFvZHhqc0NDOHBDVTVFZ2poOVFEZ0hzbmlKNXZXRWt4WkdQUTRTWElqNHR4aDh1WE1JMG1oNTdCV0pSSzB6SklEelpDeHVidHJPcFdvUW5WdmcvWlYrVGhneTBQOW03ZThPSGJhTTNVLzdwNERCZDFNWjk1ak53amVmTWVENWhSNDZUMzVya1I5dy9lYkVJS2hHanowVUIyeVJVWlBPUHFCelZmaXhZQTZnZmQ1YzFBaGpsdUN5Q3FoTEVNZCBHZW5lcmF0ZWQtYnktTm92YQogIC0gbmFtZTogd29yZHByZXNzCiAgICBzdWRvOiBmYWxzZQogICAgZ3JvdXBzOiBbd3d3LWRhdGFdCiAgICBzaGVsbDogL2Jpbi9iYXNoCiAgICBsb2NrX3Bhc3N3ZDogZmFsc2UKd3JpdGVfZmlsZXM6CiAgLSBwYXRoOiAiL2V0Yy9lbnZpcm9ubWVudCIKICAgIGNvbnRlbnQ6ICJaWGh3YjNKMElGQkJVMU5mVFZsVFVVeGZVazlQVkQxaGMyUm1ZWE5rWmdwbGVIQnZjblFnVUVGVFUxOU5XVk5SVEY5WFVGOVZVMFZTUFdGelpHWmhjMlJtQ21WNGNHOXlkQ0JRUVZOVFgxZFBVa1JRVWtWVFV6MWhjMlJtWVhOa1pnbz0iCiAgICBlbmNvZGluZzogYmFzZTY0CiAgICBhcHBlbmQ6IHRydWUKICAtIHBhdGg6ICIvZXRjL3NzaC9zc2hkX2NvbmZpZyIKICAgIGNvbnRlbnQ6ICJVRzl5ZENBeE16VTFDbEJsY20xcGRGSnZiM1JNYjJkcGJpQnVid3BRWVhOemQyOXlaRUYxZEdobGJuUnBZMkYwYVc5dUlIbGxjd289IgogICAgYXBwZW5kOiB0cnVlCiAgICBlbmNvZGluZzogYmFzZTY0CiAgLSBwYXRoOiAiL2V0Yy9sZW1wLWluc3RhbGwuc2giCiAgICBlbmNvZGluZzogYmFzZTY0CiAgICBwZXJtaXNzaW9uczogIjcwMCIKICAgIGNvbnRlbnQ6IEl5RXZZbWx1TDJKaGMyZ0tDbk5sZENBdFpRb0tJeUJrWldaaGRXeDBJRzV2Ym1VS1JFOU5RVWxPWDA5U1gwNVBUa1U5Q2lNZ1pHVm1ZWFZzZENBaVpHVm1ZWFZzZENJS1JFOU5RVWxPWDA5U1gwUkZSa0ZWVEZROUltUmxabUYxYkhRaUNnb2pJRWx1YzNSaGJHd2djR0ZqYTJGblpYTUtZWEIwSUhWd1pHRjBaU0I4ZkNCMGNuVmxDbUZ3ZENCcGJuTjBZV3hzSUMxNUlHNW5hVzU0SUcxaGNtbGhaR0l0YzJWeWRtVnlJSEJvY0MxbWNHMGdjR2h3TFcxNWMzRnNJSEJvY0MxamRYSnNJSEJvY0MxblpDQndhSEF0YVc1MGJDQndhSEF0YldKemRISnBibWNnY0dod0xYTnZZWEFnY0dod0xYaHRiQ0J3YUhBdGVHMXNjbkJqSUhCb2NDMTZhWEFLQ2lNZ1EyOXVabWxuZFhKbElHMWhjbWxoWkdJS2MzbHpkR1Z0WTNSc0lITjBiM0FnYlhsemNXd0thMmxzYkdGc2JDQXRPU0J0ZVhOeGJHUmZjMkZtWlNCdGVYTnhiR1FnYldGeWFXRmtZaUJ0WVhKcFlXUmlaQ0J0ZVhOeGJDQjhmQ0IwY25WbENtVmphRzhnSWtScGMyRmliR2x1WnlCbmNtRnVkQ0IwWVdKc1pYTWdZVzVrSUc1bGRIZHZjbXRwYm1jaUNtMTVjM0ZzWkY5ellXWmxJQzB0YzJ0cGNDMW5jbUZ1ZEMxMFlXSnNaWE1nTFMxemEybHdMVzVsZEhkdmNtdHBibWNnSmo0dlpHVjJMMjUxYkd3Z0ppQmthWE52ZDI0S1pXTm9ieUFpVjJGcGRHbHVaeUJtYjNJZ2JYbHpjV3dnZEc4Z2MzUmhjblFpQ25Oc1pXVndJREV3Q20xNWMzRnNJQzExY205dmRDQXRaU0FpUmt4VlUwZ2dVRkpKVmtsTVJVZEZVenNnUVV4VVJWSWdWVk5GVWlBbmNtOXZkQ2RBSjJ4dlkyRnNhRzl6ZENjZ1NVUkZUbFJKUmtsRlJDQkNXU0FuSkZCQlUxTmZUVmxUVVV4ZlVrOVBWQ2M3SUNJS2EybHNiR0ZzYkNBdE9TQnRlWE54YkdSZmMyRm1aU0J0WVhKcFlXUmlaQ0I4ZkNCMGNuVmxDbVZqYUc4Z0lsSmxjM1JoY25ScGJtY2diWGx6Y1d3aUNuTjVjM1JsYldOMGJDQnpkR0Z5ZENCdGVYTnhiQW9LYlhsemNXd2dMUzExYzJWeVBYSnZiM1FnTFMxd1lYTnpkMjl5WkQwa2UxQkJVMU5mVFZsVFVVeGZVazlQVkgwZ0xXVWdJZ3BFUlV4RlZFVWdSbEpQVFNCdGVYTnhiQzUxYzJWeUlGZElSVkpGSUZWelpYSTlKM0p2YjNRbklFRk9SQ0JJYjNOMElFNVBWQ0JKVGlBb0oyeHZZMkZzYUc5emRDY3NJQ2N4TWpjdU1DNHdMakVuTENBbk9qb3hKeWs3Q2tSRlRFVlVSU0JHVWs5TklHMTVjM0ZzTG5WelpYSWdWMGhGVWtVZ1ZYTmxjajBuSnpzS1JFVk1SVlJGSUVaU1QwMGdiWGx6Y1d3dVpHSWdWMGhGVWtVZ1JHSTlKM1JsYzNRbklFOVNJRVJpUFNkMFpYTjBYeVVuT3dwRFVrVkJWRVVnVlZORlVpQW5kMjl5WkhCeVpYTnpkWE5sY2lkQUoyeHZZMkZzYUc5emRDY2dTVVJGVGxSSlJrbEZSQ0JDV1NBbkpIdFFRVk5UWDAxWlUxRk1YMWRRWDFWVFJWSjlKenNLUTFKRlFWUkZJRVJCVkVGQ1FWTkZJSGR2Y21Sd2NtVnpjeUJFUlVaQlZVeFVJRU5JUVZKQlExUkZVaUJUUlZRZ2RYUm1PQ0JEVDB4TVFWUkZJSFYwWmpoZmRXNXBZMjlrWlY5amFUc0tSMUpCVGxRZ1FVeE1JRTlPSUhkdmNtUndjbVZ6Y3k0cUlGUlBJQ2QzYjNKa2NISmxjM04xYzJWeUowQW5iRzlqWVd4b2IzTjBKenNLUmt4VlUwZ2dVRkpKVmtsTVJVZEZVenNnSWdvS0l5QkRiMjVtYVdkMWNtVWdjR2h3Q25ONWMzUmxiV04wYkNCeVpYTjBZWEowSUhCb2NEY3VOQzFtY0cwS0NpTWdRMjl1Wm1sbmRYSmxJRzVuYVc1NENtMXJaR2x5SUMxd0lDOTJZWEl2ZDNkM0x5UkVUMDFCU1U1ZlQxSmZUazlPUlNBS1kyaHZkMjRnTFZJZ2QyOXlaSEJ5WlhOek9uZHZjbVJ3Y21WemN5QXZkbUZ5TDNkM2R5OGtSRTlOUVVsT1gwOVNYMDVQVGtVS2RHOTFZMmdnTDJWMFl5OXVaMmx1ZUM5emFYUmxjeTFoZG1GcGJHRmliR1V2SkVSUFRVRkpUbDlQVWw5RVJVWkJWVXhVQ21WamFHOGdJaU1nWjJWdVpYSmhkR1ZrSURJd01qTXRNRFV0TWprc0lFMXZlbWxzYkdFZ1IzVnBaR1ZzYVc1bElIWTFMamNzSUc1bmFXNTRJREV1TVRjdU55d2dUM0JsYmxOVFRDQXhMakV1TVdzc0lHbHVkR1Z5YldWa2FXRjBaU0JqYjI1bWFXZDFjbUYwYVc5dUNpTWdhSFIwY0hNNkx5OXpjMnd0WTI5dVptbG5MbTF2ZW1sc2JHRXViM0puTHlOelpYSjJaWEk5Ym1kcGJuZ21kbVZ5YzJsdmJqMHhMakUzTGpjbVkyOXVabWxuUFdsdWRHVnliV1ZrYVdGMFpTWnZjR1Z1YzNOc1BURXVNUzR4YXlabmRXbGtaV3hwYm1VOU5TNDNDbk5sY25abGNpQjdDaUFnSUNCc2FYTjBaVzRnT0RBN0NpQWdJQ0JzYVhOMFpXNGdXem82WFRvNE1Ec0tDaUFnSUNCeWIyOTBJQzkyWVhJdmQzZDNMeVJFVDAxQlNVNWZUMUpmVGs5T1JUc0tJQ0FnSUdsdVpHVjRJR2x1WkdWNExuQm9jQ0JwYm1SbGVDNW9kRzFzSUdsdVpHVjRMbWgwYlRzS0NpQWdJQ0J6WlhKMlpYSmZibUZ0WlNBa1JFOU5RVWxPWDA5U1gwUkZSa0ZWVEZRN0Nnb2dJQ0FnYkc5allYUnBiMjRnTHlCN0NpQWdJQ0FnSUNBZ0l5QjBjbmxmWm1sc1pYTWdKSFZ5YVNBa2RYSnBMeUE5TkRBME93b2dJQ0FnSUNBZ0lIUnllVjltYVd4bGN5QWtkWEpwSUNSMWNta3ZJQzlwYm1SbGVDNXdhSEFrYVhOZllYSm5jeVJoY21kek93b2dJQ0FnZlFvS0lDQWdJR3h2WTJGMGFXOXVJSDRnWEM1d2FIQWtJSHNLSUNBZ0lDQWdJQ0JwYm1Oc2RXUmxJSE51YVhCd1pYUnpMMlpoYzNSaloya3RjR2h3TG1OdmJtWTdDaUFnSUNBZ0lDQWdabUZ6ZEdObmFWOXdZWE56SUhWdWFYZzZMM1poY2k5eWRXNHZjR2h3TDNCb2NEY3VOQzFtY0cwdWMyOWphenNLSUNBZ0lIMEtDaUFnSUNBaklFUnBaMmwwWVd4dlkyVmhiaUIzYjNKa2NISmxjM01LSUNBZ0lHeHZZMkYwYVc5dUlEMGdMMlpoZG1samIyNHVhV052SUhzZ2JHOW5YMjV2ZEY5bWIzVnVaQ0J2Wm1ZN0lHRmpZMlZ6YzE5c2IyY2diMlptT3lCOUNpQWdJQ0JzYjJOaGRHbHZiaUE5SUM5eWIySnZkSE11ZEhoMElIc2diRzluWDI1dmRGOW1iM1Z1WkNCdlptWTdJR0ZqWTJWemMxOXNiMmNnYjJabU95QmhiR3h2ZHlCaGJHdzdJSDBLSUNBZ0lHeHZZMkYwYVc5dUlINHFJRnd1S0dOemMzeG5hV1o4YVdOdmZHcHdaV2Q4YW5CbmZHcHpmSEJ1Wnlra0lIc0tJQ0FnSUNBZ0lDQmxlSEJwY21WeklHMWhlRHNLSUNBZ0lDQWdJQ0JzYjJkZmJtOTBYMlp2ZFc1a0lHOW1aanNLSUNBZ0lIMEtmUW9LSXlCelpYSjJaWElnZXdvaklDQWdJQ0JzYVhOMFpXNGdORFF6SUhOemJDQm9kSFJ3TWpzS0l5QWdJQ0FnYkdsemRHVnVJRnM2T2wwNk5EUXpJSE56YkNCb2RIUndNanNLQ2lNZ0lDQWdJSE56YkY5alpYSjBhV1pwWTJGMFpTQXZjR0YwYUM5MGJ5OXphV2R1WldSZlkyVnlkRjl3YkhWelgybHVkR1Z5YldWa2FXRjBaWE03Q2lNZ0lDQWdJSE56YkY5alpYSjBhV1pwWTJGMFpWOXJaWGtnTDNCaGRHZ3ZkRzh2Y0hKcGRtRjBaVjlyWlhrN0NpTWdJQ0FnSUhOemJGOXpaWE56YVc5dVgzUnBiV1Z2ZFhRZ01XUTdDaU1nSUNBZ0lITnpiRjl6WlhOemFXOXVYMk5oWTJobElITm9ZWEpsWkRwTmIzcFRVMHc2TVRCdE95QWdJeUJoWW05MWRDQTBNREF3TUNCelpYTnphVzl1Y3dvaklDQWdJQ0J6YzJ4ZmMyVnpjMmx2Ymw5MGFXTnJaWFJ6SUc5bVpqc0tDaU1nSUNBZ0lDTWdZM1Z5YkNCb2RIUndjem92TDNOemJDMWpiMjVtYVdjdWJXOTZhV3hzWVM1dmNtY3ZabVprYUdVeU1EUTRMblI0ZENBK0lDOXdZWFJvTDNSdkwyUm9jR0Z5WVcwS0l5QWdJQ0FnYzNOc1gyUm9jR0Z5WVcwZ0wzQmhkR2d2ZEc4dlpHaHdZWEpoYlRzS0NpTWdJQ0FnSUNNZ2FXNTBaWEp0WldScFlYUmxJR052Ym1acFozVnlZWFJwYjI0S0l5QWdJQ0FnYzNOc1gzQnliM1J2WTI5c2N5QlVURk4yTVM0eUlGUk1VM1l4TGpNN0NpTWdJQ0FnSUhOemJGOWphWEJvWlhKeklFVkRSRWhGTFVWRFJGTkJMVUZGVXpFeU9DMUhRMDB0VTBoQk1qVTJPa1ZEUkVoRkxWSlRRUzFCUlZNeE1qZ3RSME5OTFZOSVFUSTFOanBGUTBSSVJTMUZRMFJUUVMxQlJWTXlOVFl0UjBOTkxWTklRVE00TkRwRlEwUklSUzFTVTBFdFFVVlRNalUyTFVkRFRTMVRTRUV6T0RRNlJVTkVTRVV0UlVORVUwRXRRMGhCUTBoQk1qQXRVRTlNV1RFek1EVTZSVU5FU0VVdFVsTkJMVU5JUVVOSVFUSXdMVkJQVEZreE16QTFPa1JJUlMxU1UwRXRRVVZUTVRJNExVZERUUzFUU0VFeU5UWTZSRWhGTFZKVFFTMUJSVk15TlRZdFIwTk5MVk5JUVRNNE5EcEVTRVV0VWxOQkxVTklRVU5JUVRJd0xWQlBURmt4TXpBMU93b2pJQ0FnSUNCemMyeGZjSEpsWm1WeVgzTmxjblpsY2w5amFYQm9aWEp6SUc5bVpqc0tDaU1nSUNBZ0lDTWdTRk5VVXlBb2JtZDRYMmgwZEhCZmFHVmhaR1Z5YzE5dGIyUjFiR1VnYVhNZ2NtVnhkV2x5WldRcElDZzJNekEzTWpBd01DQnpaV052Ym1SektRb2pJQ0FnSUNCaFpHUmZhR1ZoWkdWeUlGTjBjbWxqZEMxVWNtRnVjM0J2Y25RdFUyVmpkWEpwZEhrZ0ltMWhlQzFoWjJVOU5qTXdOekl3TURBaUlHRnNkMkY1Y3pzS0NpTWdJQ0FnSUNNZ1QwTlRVQ0J6ZEdGd2JHbHVad29qSUNBZ0lDQnpjMnhmYzNSaGNHeHBibWNnYjI0N0NpTWdJQ0FnSUhOemJGOXpkR0Z3YkdsdVoxOTJaWEpwWm5rZ2IyNDdDZ29qSUNBZ0lDQWpJSFpsY21sbWVTQmphR0ZwYmlCdlppQjBjblZ6ZENCdlppQlBRMU5RSUhKbGMzQnZibk5sSUhWemFXNW5JRkp2YjNRZ1EwRWdZVzVrSUVsdWRHVnliV1ZrYVdGMFpTQmpaWEowY3dvaklDQWdJQ0J6YzJ4ZmRISjFjM1JsWkY5alpYSjBhV1pwWTJGMFpTQXZjR0YwYUM5MGJ5OXliMjkwWDBOQlgyTmxjblJmY0d4MWMxOXBiblJsY20xbFpHbGhkR1Z6T3dvS0l5QWdJQ0FnSXlCeVpYQnNZV05sSUhkcGRHZ2dkR2hsSUVsUUlHRmtaSEpsYzNNZ2IyWWdlVzkxY2lCeVpYTnZiSFpsY2dvaklDQWdJQ0J5WlhOdmJIWmxjaUF4TWpjdU1DNHdMakU3Q2lOOUlpQStJQzlsZEdNdmJtZHBibmd2YzJsMFpYTXRZWFpoYVd4aFlteGxMeVJFVDAxQlNVNWZUMUpmUkVWR1FWVk1WQXBzYmlBdGN5QXZaWFJqTDI1bmFXNTRMM05wZEdWekxXRjJZV2xzWVdKc1pTOGtSRTlOUVVsT1gwOVNYMFJGUmtGVlRGUWdMMlYwWXk5dVoybHVlQzl6YVhSbGN5MWxibUZpYkdWa0x5UkVUMDFCU1U1ZlQxSmZSRVZHUVZWTVZDQjhmQ0IwY25WbENtNW5hVzU0SUMxMENuTjVjM1JsYldOMGJDQnlaV3h2WVdRZ2JtZHBibmdLQ2lNZ1NXNXpkR0ZzYkNCM2IzSmtjSEpsYzNNS2NtMGdMWEptSUM5MllYSXZkM2QzTDJoMGJXd3ZLZ3AzWjJWMElDMVFJQzkwYlhBdklHaDBkSEJ6T2k4dmQyOXlaSEJ5WlhOekxtOXlaeTlzWVhSbGMzUXVlbWx3Q25WdWVtbHdJQzkwYlhBdmJHRjBaWE4wTG5wcGNDQXRaQ0F2ZEcxd0NtMTJJQzkwYlhBdmQyOXlaSEJ5WlhOekx5b2dMM1poY2k5M2QzY3ZKRVJQVFVGSlRsOVBVbDlPVDA1RkNnb2pJRVpwZUNCbWIyeGtaWElnY0dWeWJXbHpjMmx2Ym5NS1kyaHRiMlFnTnpVMUlDMVNJQzkyWVhJdmQzZDNMd3BqYUc5M2JpQjNkM2N0WkdGMFlUcDNkM2N0WkdGMFlTQXRVaUF2ZG1GeUwzZDNkeTg9CnJ1bmNtZDoKICAtIGNwIC9ldGMvc2tlbC8uYmFzaHJjIC9ob21lL2RyZXcvLnByb2ZpbGUKICAtIHNlZCAtaSAncy8jZm9yY2VfY29sb3JfcHJvbXB0PXllcy9mb3JjZV9jb2xvcl9wcm9tcHQ9eWVzL2cnIC9ob21lL2RyZXcvLnByb2ZpbGUKICAtIGNob3duIGRyZXc6ZHJldyAvaG9tZS9kcmV3Ly5wcm9maWxlCiAgLSBzeXN0ZW1jdGwgcmVzdGFydCBzc2gKICAtIC9ldGMvbGVtcC1pbnN0YWxsLnNoCg==")
    content_type = "text/cloud-config"
  }
}

output "cloud-config" {
  value = data.cloudinit_config.cloud-config.rendered
}