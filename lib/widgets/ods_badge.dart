import 'package:flutter/material.dart';

import '../utils/ods.dart';

/// Faixa colorida identificando um ODS da ONU atendido pelo app.
class OdsBadge extends StatelessWidget {
  const OdsBadge({super.key, required this.ods, this.mostrarDescricao = false});

  final OdsInfo ods;
  final bool mostrarDescricao;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ODS ${ods.numero}: ${ods.titulo}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ods.cor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                '${ods.numero}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ODS ${ods.numero}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    ods.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (mostrarDescricao) ...[
                    const SizedBox(height: 6),
                    Text(
                      ods.descricao,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
