import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget reutilizable para fondos con gradiente VOXIA
class VoxiaBackground extends StatelessWidget {
  final Widget child;
  final bool useGradient;
  
  const VoxiaBackground({
    super.key,
    required this.child,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!useGradient) {
      return child;
    }
    
    return Container(
      decoration: const BoxDecoration(
        gradient: VoxiaColors.backgroundGradient,
      ),
      child: child,
    );
  }
}

/// Tarjeta estilizada VOXIA
class VoxiaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool showGradientBorder;
  
  const VoxiaCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.showGradientBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
    
    if (showGradientBorder) {
      card = Container(
        decoration: BoxDecoration(
          gradient: VoxiaColors.accentGradient,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(2),
        child: card,
      );
    }
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    
    return card;
  }
}

/// Botón con gradiente VOXIA
class VoxiaGradientButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  
  const VoxiaGradientButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 54,
      decoration: BoxDecoration(
        gradient: onPressed != null 
          ? VoxiaColors.primaryGradient 
          : LinearGradient(
              colors: [Colors.grey.shade400, Colors.grey.shade500],
            ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: onPressed != null ? [
          BoxShadow(
            color: VoxiaColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón secundario con borde VOXIA
class VoxiaOutlinedButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? width;
  
  const VoxiaOutlinedButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: VoxiaColors.primary,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: VoxiaColors.primary, size: 20),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: VoxiaColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header con logo de VOXIA
class VoxiaHeader extends StatelessWidget {
  final bool showLogo;
  final bool showTitle;
  final double logoSize;
  
  const VoxiaHeader({
    super.key,
    this.showLogo = true,
    this.showTitle = true,
    this.logoSize = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLogo)
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              color: VoxiaColors.accentLight,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: VoxiaColors.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderLogo();
                },
              ),
            ),
          ),
        if (showLogo && showTitle) const SizedBox(height: 16),
        if (showTitle)
          ShaderMask(
            shaderCallback: (bounds) => VoxiaColors.primaryGradient.createShader(bounds),
            child: const Text(
              'VOXIA',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
        if (showTitle) ...[
          const SizedBox(height: 4),
          Text(
            'Tu guía de medicación accesible',
            style: TextStyle(
              fontSize: 14,
              color: VoxiaColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildPlaceholderLogo() {
    return Container(
      decoration: BoxDecoration(
        gradient: VoxiaColors.accentGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Icon(
          Icons.medication_rounded,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Sección informativa con ícono
class VoxiaInfoSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final VoidCallback? onAudioPressed;
  
  const VoxiaInfoSection({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.onAudioPressed,
  });

  @override
  Widget build(BuildContext context) {
    return VoxiaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: VoxiaColors.accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: VoxiaColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: VoxiaColors.primaryDark,
                  ),
                ),
              ),
              if (onAudioPressed != null)
                IconButton(
                  onPressed: onAudioPressed,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: VoxiaColors.accentGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  tooltip: 'Escuchar',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: VoxiaColors.textMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicador de carga VOXIA
class VoxiaLoadingIndicator extends StatelessWidget {
  final String? message;
  
  const VoxiaLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: VoxiaColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: VoxiaColors.primary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: VoxiaColors.textMedium,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state widget
class VoxiaEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  
  const VoxiaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: VoxiaColors.accentLight.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: VoxiaColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VoxiaColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: VoxiaColors.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
