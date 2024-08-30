import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions

# Função de exemplo para transformar os dados
def transform_fn(element):
    return element * element

def run():
    # Definir as opções de pipeline
    options = PipelineOptions()

    # Criação de pipeline com Apache Beam
    with beam.Pipeline(options=options) as p:
        # Definir a fonte de dados
        input_collection = p | 'Create' >> beam.Create([1, 2, 3, 4, 5])

        # Aplicar transformação de exemplo
        output_collection = input_collection | 'Transform' >> beam.Map(transform_fn)

        # Imprimir o resultado
        output_collection | 'Print' >> beam.Map(print)

if __name__ == '__main__':
    run()
